# RC smoke test

1. Parse `netlists/rc.cir` with `parser/SpiceNetlist.hs`.
2. Stamp R=1000, C=1e-6 into G, C via `numerical/MNA.jl`.
3. Form backward-Euler A at dt=1e-6.
4. Solve Ax=b for a step input; check `Residual.L2 < 1e-9`.
5. Encode four Boolean predicates (KCL, Ohm, residual, energy) into `quantum/predicates.qasm`.
6. Confirm `AcceptQASM → Valid_ε` obligation in `verification/Refinement.lean`.
