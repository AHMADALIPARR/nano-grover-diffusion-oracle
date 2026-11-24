# SPARK Contracts → Continuous DAEs: Cross-Domain Specification Mapping

## Formal Inversion Principle

A SPARK contract of the form

```text
{Pre(S)}  Cmd  {Post(S, S')}
```

is inverted into a system of Differential-Algebraic Equations (DAEs) where:

| SPARK element              | Continuous image                          |
|----------------------------|-------------------------------------------|
| Logical pre-conditions     | Initial charging states                   |
| Post-conditions            | Steady-state voltage attractors           |
| Runtime assertion failures | Hard physical clamping rails / current steering limits |

The inverted graph is serialised in `graph/dae_inverted_graph.xml`.

## Discrete-to-Continuous Invariant Mapping

| SPARK / Mathematical Contract       | Verilog-A Analog Representation          | Transistor Semiconductor Equivalent        |
|-------------------------------------|------------------------------------------|--------------------------------------------|
| Bounded Integer Range (0 ≤ v ≤ N)   | Voltage Rails (0 V to V_dd)              | Supply clamping and saturation limits      |
| State Invariant (Post(S, S'))       | Steady-state nodal balance (dV/dt = 0)   | Equilibrium collector/drain current balance|
| Matrix Multiplier (ρ(σ_k))          | Linear voltage-controlled voltage source | Gilbert cell / Translinear multiplier core |
| FNV-1a / Hash Integrity             | Non-linear mixing stage                  | Cross-coupled mixer with exponential response |

## Ada SPARK Sources

| Unit                              | Role                                              |
|-----------------------------------|---------------------------------------------------|
| `spark/nano_grover_contracts.ads/.adb` | Core amplitude, oracle, diffusion, braid, mix contracts |
| `spark/braid_chord_contracts.ads/.adb` | Chord frequency look-up contracts (flop-ROM dual) |

## Semiconductor Bounds (summary)

- **Thermal voltage** V_T ≈ 25.85 mV — translinear scaling must be temperature-compensated.
- **Inversion region** — devices kept in designated weak/strong inversion to avoid harmonic distortion.
- **Power-delay** — latency bounded by transit frequency f_T.
- **Mobility degradation** — velocity saturation ceilings high-frequency braid throughput.
- **Subthreshold leakage** — isolation switches protect continuous-time charge packets.
