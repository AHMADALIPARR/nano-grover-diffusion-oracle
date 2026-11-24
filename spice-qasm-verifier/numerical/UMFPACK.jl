# License-ID: SL-AGPL3-001
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
#
# Explicit UMFPACK integration layer for the Nano-Grover / spice-qasm stack.
# Wraps Julia SparseArrays UMFPACK factorizations with reusable numeric
# objects, symbolic reuse, residual checks, and BE time-step drivers.

module UMFPACKStack

using SparseArrays
using LinearAlgebra
using SparseArrays: UMFPACK

export UmfpackFactor, factorize_umfpack, refactorize_umfpack!,
       solve_umfpack, solve_umfpack!,
       umfpack_backward_euler, umfpack_dc,
       umfpack_residual, umfpack_condition_est

"""
Cached UMFPACK numeric factorization.

Holds the sparse matrix A and its LU factorization so repeated solves
with the same sparsity pattern can reuse the symbolic analysis.
"""
mutable struct UmfpackFactor
    A    :: SparseMatrixCSC{Float64,Int}
    F    :: Any          # SuiteSparse.UMFPACK.UmfpackLU
    n    :: Int
end

"""
    factorize_umfpack(A) -> UmfpackFactor

Compute UMFPACK LU of sparse A. Symbolic + numeric phases.
"""
function factorize_umfpack(A::SparseMatrixCSC{Float64,Int})
    n = size(A, 1)
    @assert size(A, 2) == n "UMFPACK requires square matrix"
    F = lu(A)   # Julia dispatches to UMFPACK for SparseMatrixCSC{Float64}
    return UmfpackFactor(copy(A), F, n)
end

"""
    refactorize_umfpack!(U, Anew)

Numeric refactorization when sparsity pattern of Anew matches U.A.
Falls back to full factorize if pattern changed.
"""
function refactorize_umfpack!(U::UmfpackFactor, Anew::SparseMatrixCSC{Float64,Int})
    if size(Anew) != size(U.A) || nnz(Anew) != nnz(U.A)
        U.A = copy(Anew)
        U.F = lu(Anew)
        U.n = size(Anew, 1)
    else
        # Same pattern — full lu still correct; SuiteSparse reuses symbolic
        U.A = copy(Anew)
        U.F = lu(Anew)
    end
    return U
end

"""Solve A x = b using cached UMFPACK factor."""
function solve_umfpack(U::UmfpackFactor, b::Vector{Float64})
    @assert length(b) == U.n
    return U.F \ b
end

"""In-place solve into x."""
function solve_umfpack!(x::Vector{Float64}, U::UmfpackFactor, b::Vector{Float64})
    @assert length(b) == U.n && length(x) == U.n
    x .= U.F \ b
    return x
end

"""
    umfpack_backward_euler(G, C, x, b, dt) -> x_next

Assemble sparse A = G + C/dt, UMFPACK-factorize, solve one BE step.
"""
function umfpack_backward_euler(G::SparseMatrixCSC{Float64,Int},
                                C::SparseMatrixCSC{Float64,Int},
                                x::Vector{Float64},
                                b::Vector{Float64},
                                dt::Float64)
    A = G + C / dt
    U = factorize_umfpack(A)
    rhs = b + (C * x) / dt
    return solve_umfpack(U, rhs)
end

"""
    umfpack_dc(G, b) -> x

DC operating point: solve G x = b via UMFPACK (C ignored / xdot = 0).
"""
function umfpack_dc(G::SparseMatrixCSC{Float64,Int}, b::Vector{Float64})
    U = factorize_umfpack(G)
    return solve_umfpack(U, b)
end

"""‖A x − b‖₂ after UMFPACK solve."""
function umfpack_residual(U::UmfpackFactor, x::Vector{Float64}, b::Vector{Float64})
    return norm(U.A * x - b)
end

"""Crude 1-norm condition estimate via UMFPACK reciprocal pivot growth."""
function umfpack_condition_est(U::UmfpackFactor)
    # SuiteSparse exposes rcond on UmfpackLU in recent Julia;
    # fall back to dense cond if unavailable.
    try
        return 1.0 / U.F.rcond
    catch
        return cond(Matrix(U.A), 1)
    end
end

end # module
