# License-ID: SL-AGPL3-001
# Modified Nodal Analysis — matrix construction (Julia).

module MNA

export stamp_G!, stamp_C!, backward_euler, residual_norm

"""Stamp conductance g between nodes i,j (1-based, ground = 0 skipped)."""
function stamp_G!(G::Matrix{Float64}, i::Int, j::Int, g::Float64)
    if i > 0
        G[i,i] += g
    end
    if j > 0
        G[j,j] += g
    end
    if i > 0 && j > 0
        G[i,j] -= g
        G[j,i] -= g
    end
    return G
end

"""Stamp capacitance c between nodes i,j into C matrix."""
function stamp_C!(C::Matrix{Float64}, i::Int, j::Int, c::Float64)
    return stamp_G!(C, i, j, c)
end

"""Backward-Euler system matrix A = G + C/dt."""
function backward_euler(G::Matrix{Float64}, C::Matrix{Float64}, dt::Float64)
    return G .+ C ./ dt
end

"""||A x - b||₂ residual."""
function residual_norm(A::Matrix{Float64}, x::Vector{Float64}, b::Vector{Float64})
    return norm(A * x - b)
end

end # module
