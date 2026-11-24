# License-ID: SL-AGPL3-001
# Smoke test: stamp RC, integrate, check steady-state and residual.

include(joinpath(@__DIR__, "..", "numerical", "MNA.jl"))
include(joinpath(@__DIR__, "..", "numerical", "DiffEq.jl"))
using .MNA
using .DiffEq
using LinearAlgebra
using Test

R = 1000.0
Cval = 1e-6
Vdc = 1.0
dt = 1e-6
tspan = (0.0, 10e-3)

G, C, b = build_rc(R, Cval, Vdc)

# Steady state: ẋ = 0 ⇒ G x = b ⇒ x = Vdc
x_ss = G \ b
@test abs(x_ss[1] - Vdc) < 1e-12

# Residual at steady state with xdot = 0
r = DiffEq.dae_residual(C, G, x_ss, zeros(1), b)
@test norm(r) < 1e-12

# Time integration toward steady state
t_hist, x_hist = DiffEq.simulate_rc(R, Cval, Vdc, tspan, dt; method=:backward_euler)
@test abs(x_hist[end][1] - Vdc) < 1e-4

println("RC MNA stamp + DiffEq smoke test OK")
println("  final Vout = ", x_hist[end][1])
