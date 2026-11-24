# License-ID: SL-AGPL3-001
# Smoke test: series RLC stamp and integration.

include(joinpath(@__DIR__, "..", "numerical", "MNA.jl"))
include(joinpath(@__DIR__, "..", "numerical", "DiffEq.jl"))
using .MNA
using .DiffEq
using LinearAlgebra
using Test

R = 10.0
L = 1e-3
Cval = 1e-6
Vdc = 1.0
dt = 1e-7
tspan = (0.0, 2e-3)

G, C, b = build_series_rlc(R, L, Cval, Vdc)

# Dimensions
@test size(G) == (3, 3)
@test size(C) == (3, 3)

# Integrate
t_hist, x_hist = DiffEq.simulate_series_rlc(R, L, Cval, Vdc, tspan, dt;
                                            method=:backward_euler)

# After several time constants, capacitor voltage should approach Vdc
v2_final = x_hist[end][2]
println("RLC MNA stamp + DiffEq smoke test")
println("  final v2 (cap) = ", v2_final)
@test abs(v2_final - Vdc) < 0.15   # loose bound for underdamped short window

println("OK")
