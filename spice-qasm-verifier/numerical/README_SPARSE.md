# SparseSolver.jl

Sparse matrix solver library for MNA linear systems arising from SPICE netlists.

## Capabilities

| API | Purpose |
|-----|---------|
| `SparseSystem` | Container for sparse G, C, b |
| `stamp_sparse_G!` / `stamp_sparse_C!` | In-place CSC stamps |
| `stamp_sparse_inductor!` | Augmented MNA inductor stamp |
| `assemble_backward_euler` | Sparse A = G + C/dt |
| `sparse_direct_solve` | UMFPACK sparse factorization (stdlib) |
| `sparse_cg_solve` | Hand-rolled CG for SPD systems |
| `sparse_gmres_solve` | Restarted GMRES for general sparse A |
| `sparse_backward_euler_step` | One BE time step on sparse matrices |
| `build_sparse_rc` / `build_sparse_series_rlc` | Reference sparse netlists |

## Usage sketch

```julia
include("SparseSolver.jl")
using .SparseSolver

sys = build_sparse_rc(1000.0, 1e-6, 1.0)
x   = sparse_direct_solve(sys, 1e6)   # large dt ≈ DC

A = assemble_backward_euler(sys.G, sys.C, 1e-6)
x, info = sparse_cg_solve(A, sys.b)
```

## Dependencies

Julia standard library only: `SparseArrays`, `LinearAlgebra`.
No external packages required.
