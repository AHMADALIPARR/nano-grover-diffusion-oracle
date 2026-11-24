# License-ID: SL-AGPL3-001
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
#
# Continuous-time differential equations from MNA:
#     C ẋ + G x = b(t)
#
# Provides:
#   - dense residual evaluation
#   - explicit Euler / backward Euler / trapezoidal steps
#   - simple adaptive forward integration for linear RC/RLC systems

module DiffEq

using LinearAlgebra

export dae_residual, explicit_euler_step, backward_euler_step,
       trapezoidal_step, integrate_linear, simulate_rc

"""
    dae_residual(C, G, x, xdot, b) -> r

Residual of the linear DAE  C ẋ + G x − b.
"""
function dae_residual(C::AbstractMatrix, G::AbstractMatrix,
                      x::AbstractVector, xdot::AbstractVector,
                      b::AbstractVector)
    return C * xdot + G * x - b
end

"""
    explicit_euler_step(C, G, x, b, dt) -> x_next

For nonsingular C:  ẋ = C⁻¹ (b − G x)
Forward Euler:      x ← x + dt · ẋ
"""
function explicit_euler_step(C::AbstractMatrix, G::AbstractMatrix,
                             x::AbstractVector, b::AbstractVector,
                             dt::Float64)
    xdot = C \ (b - G * x)
    return x + dt * xdot
end

"""
    backward_euler_step(C, G, x, b, dt) -> x_next

Solve  (G + C/dt) x⁺ = b + (C/dt) x
"""
function backward_euler_step(C::AbstractMatrix, G::AbstractMatrix,
                             x::AbstractVector, b::AbstractVector,
                             dt::Float64)
    A = G + C ./ dt
    rhs = b + (C * x) ./ dt
    return A \ rhs
end

"""
    trapezoidal_step(C, G, x, b, b_next, dt) -> x_next

Trapezoidal rule (fixed-step):
  (G + 2C/dt) x⁺ = (2C/dt − G) x + (b + b_next)
"""
function trapezoidal_step(C::AbstractMatrix, G::AbstractMatrix,
                          x::AbstractVector,
                          b::AbstractVector, b_next::AbstractVector,
                          dt::Float64)
    A   = G + (2.0 / dt) .* C
    rhs = ((2.0 / dt) .* C - G) * x + (b + b_next)
    return A \ rhs
end

"""
    integrate_linear(C, G, x0, b_func, tspan, dt; method=:backward_euler)

Integrate the linear DAE over tspan = (t0, t1) with fixed dt.
`b_func(t)` returns the source vector at time t.
Returns (t_hist, x_hist).
"""
function integrate_linear(C::AbstractMatrix, G::AbstractMatrix,
                          x0::AbstractVector,
                          b_func,
                          tspan::Tuple{Float64,Float64},
                          dt::Float64;
                          method::Symbol = :backward_euler)
    t0, t1 = tspan
    t = t0
    x = copy(x0)
    t_hist = Float64[t]
    x_hist = [copy(x)]

    while t < t1 - 0.5*dt
        b_now = b_func(t)
        if method === :explicit_euler
            x = explicit_euler_step(C, G, x, b_now, dt)
        elseif method === :backward_euler
            b_next = b_func(t + dt)
            x = backward_euler_step(C, G, x, b_next, dt)
        elseif method === :trapezoidal
            b_next = b_func(t + dt)
            x = trapezoidal_step(C, G, x, b_now, b_next, dt)
        else
            error("Unknown method $method")
        end
        t += dt
        push!(t_hist, t)
        push!(x_hist, copy(x))
    end
    return t_hist, x_hist
end

"""
    simulate_rc(R, Cval, Vdc, tspan, dt; method=:backward_euler)

Convenience: single-node RC low-pass driven by a DC source through R.
MNA dimension = 1 (output node).
  G = [1/R],  C = [Cval],  b = [Vdc/R]
"""
function simulate_rc(R::Float64, Cval::Float64, Vdc::Float64,
                     tspan::Tuple{Float64,Float64}, dt::Float64;
                     method::Symbol = :backward_euler)
    g = 1.0 / R
    G = fill(g, 1, 1)
    C = fill(Cval, 1, 1)
    x0 = [0.0]
    b_func = _ -> [Vdc * g]
    return integrate_linear(C, G, x0, b_func, tspan, dt; method=method)
end

"""
    simulate_series_rlc(R, L, Cval, Vdc, tspan, dt; method=:backward_euler)

Series RLC with nodes: in --R-- n1 --L-- n2 --C-- gnd
Augmented MNA unknowns: [v_n1, v_n2, i_L]
"""
function simulate_series_rlc(R::Float64, L::Float64, Cval::Float64,
                             Vdc::Float64,
                             tspan::Tuple{Float64,Float64}, dt::Float64;
                             method::Symbol = :backward_euler)
    # Unknowns: x = [v1, v2, iL]
    n = 3
    G = zeros(n, n)
    C = zeros(n, n)

    # R from ideal voltage source node (absorbed into b) to n1:
    # treat input as known Vdc driving through R into n1
    g = 1.0 / R
    G[1,1] += g          # n1 to "in" conductance (in fixed at Vdc)

    # Inductor branch between n1 and n2, current iL = x[3]
    G[1,3] += 1.0
    G[2,3] -= 1.0
    G[3,1] -= 1.0
    G[3,2] += 1.0
    C[3,3] += L          # L diL/dt

    # Capacitor n2 to ground
    C[2,2] += Cval

    x0 = zeros(n)
    # b: current injected into n1 from the Thevenin source Vdc/R
    b_func = _ -> [Vdc * g, 0.0, 0.0]

    return integrate_linear(C, G, x0, b_func, tspan, dt; method=method)
end

end # module
