# spice-qasm-verifier

SPICE → mathematical constraints → OpenQASM verification backend.

## Architecture

```
SPICE netlist
    ↓  parser (Haskell)
Abstract elements
    ↓  MNA stamping (WhyML contracts + Lean semantics + Julia numerics)
C ẋ + G x = b(t)
    ↓  backward Euler
A x = b
    ↓  Hermitian embedding (optional quantum LSQ)
OpenQASM predicates / linear-system circuits
    ↓
Accept_QASM(N)  ⟹  Valid_ε(N)
```

## Directory layout

| Path | Role |
|------|------|
| `netlists/` | Reference SPICE decks (RC, RLC, MOSFET) |
| `parser/` | Haskell netlist AST |
| `semantics/` | Lean 4 Kirchhoff, devices, MNA, stability |
| `contracts/` | WhyML stamp & discretization contracts |
| `numerical/` | Julia MNA / Hermitian / residual |
| `quantum/` | OpenQASM predicate & linear-system circuits |
| `calibration/` | OpenPulse control fragments |
| `verification/` | Refinement & error-bound Lean modules |
| `tests/` | Smoke-test scripts |

## Cross-domain (shared with parent project)

| SPARK Contract | Verilog-A | Transistor |
|----------------|-----------|------------|
| Bounded Integer | Voltage Rails | Supply clamping |
| State Invariant | Steady-state nodal balance | Collector/drain equilibrium |
| Matrix Multiplier | VCVS / Gilbert cell | Translinear loop |
| Hash Integrity | Non-linear mixing | Exponential mixer |

## License

SL-AGPL3-001 / AGPLv3
