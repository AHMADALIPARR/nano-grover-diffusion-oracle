# License-ID: SL-AGPL3-001
# UMFPACK stack smoke: RC DC, BE step, residual, condition.

include(joinpath(@__DIR__, "..", "numerical", "SparseSolver.jl"))
include(joinpath(@__DIR__, "..", "numerical", "UMFPACK.jl"))
using .SparseSolver
using .UMFPACKStack
using LinearAlgebra
using Test

sys = SparseSolver.build_sparse_rc(1000.0, 1e-6, 1.0)

# DC via UMFPACK
x_dc = UMFPACKStack.umfpack_dc(sys.G, sys.b)
@test abs(x_dc[1] - 1.0) < 1e-12

# BE step from zero
x0 = zeros(1)
x1 = UMFPACKStack.umfpack_backward_euler(sys.G, sys.C, x0, sys.b, 1e-6)
@test x1[1] > 0.0 && x1[1] < 1.0

# Factor cache + residual
A = SparseSolver.assemble_backward_euler(sys.G, sys.C, 1e6)
U = UMFPACKStack.factorize_umfpack(A)
x  = UMFPACKStack.solve_umfpack(U, sys.b)
@test UMFPACKStack.umfpack_residual(U, x, sys.b) < 1e-12

κ = UMFPACKStack.umfpack_condition_est(U)
@test isfinite(κ) && κ > 0

println("UMFPACK stack smoke OK")
println("  DC Vout = ", x_dc[1])
println("  BE step Vout = ", x1[1])
println("  cond est = ", κ)
