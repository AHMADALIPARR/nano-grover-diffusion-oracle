# License-ID: SL-AGPL3-001
# Residual and energy observables for verification.

module Residual

export L2, energy_bound_ok

"""ℒ(x) = ||A x - b||²"""
function L2(A, x, b)
    r = A * x - b
    return real(dot(r, r))
end

"""Energy boundedness check."""
function energy_bound_ok(energy::Float64, Emax::Float64)
    return energy ≤ Emax
end

end # module
