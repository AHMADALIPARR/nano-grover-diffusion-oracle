# License-ID: SL-AGPL3-001
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
#
# Sparse matrix solver library for MNA linear systems.
#
#   A x = b     with A sparse (CSC)
#
# Provides:
#   - sparse stamp helpers (increment CSC entries safely)
#   - sparse backward-Euler matrix assembly
#   - direct sparse solve (UMFPACK via SparseArrays / LinearAlgebra)
#   - iterative CG / GMRES wrappers with residual reporting
#   - drop-in replacements for dense DiffEq steps on large nets

module SparseSolver

using SparseArrays
using LinearAlgebra

export SparseSystem,
       sparse_zeros, stamp_sparse_G!, stamp_sparse_C!,
       assemble_backward_euler, sparse_direct_solve,
       sparse_cg_solve, sparse_gmres_solve,
       sparse_backward_euler_step, sparse_residual_norm,
       from_dense

# ---------------------------------------------------------------------------
# System container
# ---------------------------------------------------------------------------

"""
    SparseSystem

Holds sparse conductance G, capacitance C, and RHS b for an MNA system.
"""
struct SparseSystem
    n :: Int
    G :: SparseMatrixCSC{Float64,Int}
    C :: SparseMatrixCSC{Float64,Int}
    b :: Vector{Float64}
end

function SparseSystem(n::Int)
    return SparseSystem(n, spzeros(n, n), spzeros(n, n), zeros(n))
end

"""Allocate an n×n sparse zero matrix."""
sparse_zeros(n::Int) = spzeros(Float64, n, n)

# ---------------------------------------------------------------------------
# Sparse stamping (mutate CSC in place via sparse accumulation)
# ---------------------------------------------------------------------------

"""
    stamp_sparse_G!(G, i, j, g)

Stamp conductance g between nodes i and j (1-based; 0 = ground).
Uses in-place update on SparseMatrixCSC.
"""
function stamp_sparse_G!(G::SparseMatrixCSC{Float64,Int}, i::Int, j::Int, g::Float64)
    if i > 0
        G[i, i] += g
    end
    if j > 0
        G[j, j] += g
    end
    if i > 0 && j > 0
        G[i, j] -= g
        G[j, i] -= g
    end
    return G
end

"""Stamp capacitance into sparse C (same pattern)."""
function stamp_sparse_C!(C::SparseMatrixCSC{Float64,Int}, i::Int, j::Int, c::Float64)
    return stamp_sparse_G!(C, i, j, c)
end

"""Stamp series inductor (augmented MNA) into sparse G and C."""
function stamp_sparse_inductor!(G::SparseMatrixCSC{Float64,Int},
                                C::SparseMatrixCSC{Float64,Int},
                                i::Int, j::Int, k::Int, L::Float64)
    if i > 0
        G[i, k] += 1.0
        G[k, i] -= 1.0
    end
    if j > 0
        G[j, k] -= 1.0
        G[k, j] += 1.0
    end
    C[k, k] += L
    return G, C
end

# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------

"""
    assemble_backward_euler(G, C, dt) -> A

Sparse A = G + C/dt.
"""
function assemble_backward_euler(G::SparseMatrixCSC{Float64,Int},
                                 C::SparseMatrixCSC{Float64,Int},
                                 dt::Float64)
    return G + C / dt
end

"""Convert dense G, C, b into a SparseSystem."""
function from_dense(G::Matrix{Float64}, C::Matrix{Float64}, b::Vector{Float64})
    n = length(b)
    return SparseSystem(n, sparse(G), sparse(C), copy(b))
end

# ---------------------------------------------------------------------------
# Direct sparse solve (UMFPACK / SuiteSparse via Julia stdlib)
# ---------------------------------------------------------------------------

"""
    sparse_direct_solve(A, b) -> x

Factor sparse A and solve A x = b.
Uses Julia's default sparse \ (UMFPACK for real nonsymmetric).
"""
function sparse_direct_solve(A::SparseMatrixCSC{Float64,Int}, b::Vector{Float64})
    return A \ b
end

"""
    sparse_direct_solve(sys, dt) -> x

Assemble backward-Euler system from SparseSystem and solve for DC-like step
with given dt (use large dt for near-DC).
"""
function sparse_direct_solve(sys::SparseSystem, dt::Float64)
    A = assemble_backward_euler(sys.G, sys.C, dt)
    return sparse_direct_solve(A, sys.b)
end

# ---------------------------------------------------------------------------
# Iterative solvers
# ---------------------------------------------------------------------------

"""
    sparse_cg_solve(A, b; atol, rtol, maxiter) -> (x, info)

Conjugate Gradient for SPD systems. Returns solution and convergence flag.
"""
function sparse_cg_solve(A::SparseMatrixCSC{Float64,Int}, b::Vector{Float64};
                         atol::Float64 = 1e-10,
                         rtol::Float64 = 1e-10,
                         maxiter::Int = 1000)
    n = length(b)
    x = zeros(n)
    # Simple hand-rolled CG (no external deps beyond stdlib)
    r = b - A * x
    p = copy(r)
    rsold = dot(r, r)
    tol2 = max(atol, rtol * norm(b))^2
    converged = false
    iter = 0
    for k in 1:maxiter
        iter = k
        Ap = A * p
        α = rsold / dot(p, Ap)
        x .+= α .* p
        r .-= α .* Ap
        rsnew = dot(r, r)
        if rsnew < tol2
            converged = true
            break
        end
        β = rsnew / rsold
        p .= r .+ β .* p
        rsold = rsnew
    end
    return x, (converged = converged, iters = iter, residual = sqrt(rsold))
end

"""
    sparse_gmres_solve(A, b; restart, atol, rtol, maxiter) -> (x, info)

Restarted GMRES for general sparse systems (thin implementation).
"""
function sparse_gmres_solve(A::SparseMatrixCSC{Float64,Int}, b::Vector{Float64};
                            restart::Int = 30,
                            atol::Float64 = 1e-10,
                            rtol::Float64 = 1e-10,
                            maxiter::Int = 300)
    n = length(b)
    x = zeros(n)
    tol = max(atol, rtol * norm(b))
    total_iters = 0
    converged = false
    final_res = norm(b)

    for outer in 1:cld(maxiter, restart)
        r0 = b - A * x
        β = norm(r0)
        if β < tol
            converged = true
            final_res = β
            break
        end
        m = min(restart, maxiter - total_iters)
        V = zeros(n, m + 1)
        H = zeros(m + 1, m)
        V[:, 1] = r0 / β
        w = zeros(n)

        for j in 1:m
            total_iters += 1
            mul!(w, A, V[:, j])
            for i in 1:j
                H[i, j] = dot(V[:, i], w)
                w .-= H[i, j] .* V[:, i]
            end
            H[j + 1, j] = norm(w)
            if H[j + 1, j] < eps(Float64)
                m = j
                break
            end
            V[:, j + 1] = w / H[j + 1, j]
        end

        # Solve least-squares  H[1:m+1,1:m] y = β e1
        e1 = zeros(m + 1)
        e1[1] = β
        y = H[1:m+1, 1:m] \ e1
        x .+= V[:, 1:m] * y
        final_res = norm(b - A * x)
        if final_res < tol
            converged = true
            break
        end
    end

    return x, (converged = converged, iters = total_iters, residual = final_res)
end

# ---------------------------------------------------------------------------
# Sparse time-step (drop-in for DiffEq dense steps)
# ---------------------------------------------------------------------------

"""
    sparse_backward_euler_step(G, C, x, b, dt) -> x_next

Sparse backward-Euler: solve (G + C/dt) x⁺ = b + (C/dt) x
"""
function sparse_backward_euler_step(G::SparseMatrixCSC{Float64,Int},
                                    C::SparseMatrixCSC{Float64,Int},
                                    x::Vector{Float64},
                                    b::Vector{Float64},
                                    dt::Float64)
    A = assemble_backward_euler(G, C, dt)
    rhs = b + (C * x) / dt
    return sparse_direct_solve(A, rhs)
end

"""‖A x − b‖₂ for sparse A."""
function sparse_residual_norm(A::SparseMatrixCSC{Float64,Int},
                              x::Vector{Float64}, b::Vector{Float64})
    return norm(A * x - b)
end

# ---------------------------------------------------------------------------
# Convenience: build sparse RC / RLC systems
# ---------------------------------------------------------------------------

"""Sparse RC low-pass (1 unknown)."""
function build_sparse_rc(R::Float64, Cval::Float64, Vdc::Float64)
    sys = SparseSystem(1)
    g = 1.0 / R
    stamp_sparse_G!(sys.G, 1, 0, g)
    sys.G[1, 1] = g
    sys.C[1, 1] = Cval
    sys.b[1] = Vdc * g
    return sys
end

"""Sparse series RLC (3 unknowns: v1, v2, iL)."""
function build_sparse_series_rlc(R::Float64, L::Float64, Cval::Float64, Vdc::Float64)
    sys = SparseSystem(3)
    g = 1.0 / R
    sys.G[1, 1] = g
    sys.b[1] = Vdc * g
    stamp_sparse_inductor!(sys.G, sys.C, 1, 2, 3, L)
    stamp_sparse_C!(sys.C, 2, 0, Cval)
    return sys
end

end # module
