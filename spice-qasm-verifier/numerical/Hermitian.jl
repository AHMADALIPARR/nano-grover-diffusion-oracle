# License-ID: SL-AGPL3-001
# Hermitian embedding of a non-Hermitian matrix A for quantum linear systems.
#
#   H = [ 0  A ]
#       [ A† 0 ]

module HermitianEmbed

export embed

"""Build Hermitian embedding H of A."""
function embed(A::Matrix{ComplexF64})
    m, n = size(A)
    @assert m == n
    H = zeros(ComplexF64, 2m, 2m)
    H[1:m, m+1:2m] = A
    H[m+1:2m, 1:m] = A'
    return H
end

function embed(A::Matrix{Float64})
    return embed(ComplexF64.(A))
end

end # module
