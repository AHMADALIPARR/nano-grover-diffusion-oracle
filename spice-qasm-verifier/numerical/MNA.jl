# License-ID: SL-AGPL3-001
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
#
# Modified Nodal Analysis — matrix construction and stamping (Julia).

module MNA

using LinearAlgebra

export stamp_G!, stamp_C!, stamp_inductor!, stamp_vsource_gnd!,
       backward_euler, residual_norm, build_rc, build_series_rlc

"""Stamp conductance g between nodes i,j (1-based; 0 = ground)."""
function stamp_G!(G::Matrix{Float64}, i::Int, j::Int, g::Float64)
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

"""Stamp capacitance c between nodes i,j into C."""
function stamp_C!(C::Matrix{Float64}, i::Int, j::Int, c::Float64)
    return stamp_G!(C, i, j, c)
end

"""
Stamp series inductor between i and j with branch-current unknown at index k.
Updates both G and C (augmented MNA).
"""
function stamp_inductor!(G::Matrix{Float64}, C::Matrix{Float64},
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

"""
Stamp independent voltage source from node i to ground.
Extra current unknown at index k; b[k] = Vdc.
"""
function stamp_vsource_gnd!(G::Matrix{Float64}, b::Vector{Float64},
                            i::Int, k::Int, Vdc::Float64)
    if i > 0
        G[i, k] += 1.0
        G[k, i] += 1.0
    end
    b[k] = Vdc
    return G, b
end

"""Backward-Euler system matrix A = G + C/dt."""
function backward_euler(G::Matrix{Float64}, C::Matrix{Float64}, dt::Float64)
    return G .+ C ./ dt
end

"""‖A x − b‖₂"""
function residual_norm(A::Matrix{Float64}, x::Vector{Float64}, b::Vector{Float64})
    return norm(A * x - b)
end

"""Build G, C, b for the reference RC low-pass (1 unknown)."""
function build_rc(R::Float64, Cval::Float64, Vdc::Float64)
    G = zeros(1, 1)
    C = zeros(1, 1)
    b = zeros(1)
    g = 1.0 / R
    stamp_G!(G, 1, 0, g)          # R from out to "in" absorbed as g to gnd + drive
    # More precisely: Thevenin drive — stamp g to ground and inject Vdc*g
    C[1, 1] = Cval
    b[1] = Vdc * g
    G[1, 1] = g
    return G, C, b
end

"""Build augmented G, C for series RLC (3 unknowns: v1, v2, iL)."""
function build_series_rlc(R::Float64, L::Float64, Cval::Float64, Vdc::Float64)
    n = 3
    G = zeros(n, n)
    C = zeros(n, n)
    b = zeros(n)
    g = 1.0 / R
    G[1, 1] = g
    b[1] = Vdc * g
    stamp_inductor!(G, C, 1, 2, 3, L)
    stamp_C!(C, 2, 0, Cval)
    return G, C, b
end

end # module
