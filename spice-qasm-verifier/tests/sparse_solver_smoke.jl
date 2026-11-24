# License-ID: SL-AGPL3-001
# Smoke tests for SparseSolver against dense MNA reference.

include(joinpath(@__DIR__, "..", "numerical", "MNA.jl"))
include(joinpath(@__DIR__, "..", "numerical", "SparseSolver.jl"))
using .MNA
using .SparseSolver
using LinearAlgebra
using SparseArrays
using Test

# ---- RC direct solve -------------------------------------------------------
R, Cval, Vdc = 1000.0, 1e-6, 1.0
dt = 1e6          # large dt ≈ DC

Gd, Cd, bd = MNA.build_rc(R, Cval, Vdc)
sys = SparseSolver.build_sparse_rc(R, Cval, Vdc)

x_dense  = (Gd .+ Cd ./ dt) \ bd
x_sparse = SparseSolver.sparse_direct_solve(sys, dt)

@test norm(x_dense - x_sparse) < 1e-12
@test abs(x_sparse[1] - Vdc) < 1e-10

# ---- sparse residual -------------------------------------------------------
A = SparseSolver.assemble_backward_euler(sys.G, sys.C, dt)
@test SparseSolver.sparse_residual_norm(A, x_sparse, sys.b) < 1e-12

# ---- CG on SPD diagonal-dominant system ------------------------------------
n = 20
As = spdiagm(0 => fill(2.0, n), 1 => fill(-0.5, n-1), -1 => fill(-0.5, n-1))
bs = ones(n)
x_cg, info_cg = SparseSolver.sparse_cg_solve(As, bs; atol=1e-12)
@test info_cg.converged
@test norm(As * x_cg - bs) < 1e-10

# ---- GMRES on nonsymmetric sparse ------------------------------------------
An = sprand(15, 15, 0.3) + 2.0 * I
bn = rand(15)
x_gm, info_gm = SparseSolver.sparse_gmres_solve(An, bn; atol=1e-10, maxiter=200)
@test info_gm.converged || info_gm.residual < 1e-8

# ---- RLC sparse step -------------------------------------------------------
sys_rlc = SparseSolver.build_sparse_series_rlc(10.0, 1e-3, 1e-6, 1.0)
x0 = zeros(3)
x1 = SparseSolver.sparse_backward_euler_step(sys_rlc.G, sys_rlc.C, x0, sys_rlc.b, 1e-7)
@test length(x1) == 3
@test all(isfinite, x1)

println("SparseSolver smoke tests OK")
println("  RC Vout (sparse) = ", x_sparse[1])
println("  CG iters = ", info_cg.iters, "  residual = ", info_cg.residual)
println("  GMRES iters = ", info_gm.iters, "  residual = ", info_gm.residual)
