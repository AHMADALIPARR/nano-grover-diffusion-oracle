# Nano-Grover Diffusion & Oracle Iteration Circuit

Formal synthesis and verification of analog **Nano-Grover** circuits, trigonometric braid processors, SPARK contracts, and their quantum / digital duals.

## Contents

### Analog (Verilog-A)

| File | Description |
|------|-------------|
| `src/nano_grover_core.va` | Continuous-time Nano-Grover diffusion & oracle core (N ≥ 8) |
| `src/nano_grover_triple_iteration.va` | 2-qubit triple-iteration Grover with collapse |
| `src/spatial_grover_lattice.va` | Spatial 2-qubit microwave / cross-resonance lattice |
| `src/trig_braid_processor.va` | Full φ-weighted braid matrix ρ(σ₁) with bounds |
| `src/trig_processor.va` | Simple sin/cos with boundary checks |
| `src/braid_trig_processor.va` | Minimal Metatron φ processor |

### Digital RTL (SystemVerilog) — Flop Algorithm Source of Truth

| File | Description |
|------|-------------|
| `rtl/braid_chord_flop_rom.sv` | **Source-of-truth** flip-flop ROM: pre-evaluated chord energy eigenvalues |
| `rtl/trig_processor.sv` | Digital dual of simple sin/cos processor |
| `rtl/trig_braid_processor.sv` | Digital dual of φ-weighted braid processor |
| `rtl/braid_trig_processor.sv` | Minimal Metatron φ processor (RTL) |

### Quantum Circuit Extensions

| File | Description |
|------|-------------|
| `rtl/quantum/q_braid_chord_rom.sv` | Amplitude-encoded 2-qubit look-up from chord eigenvalues |
| `rtl/quantum/q_grover_flop_stage.sv` | Single Grover iteration in flip-flop amplitude registers |

### Ada SPARK Contracts

| File | Description |
|------|-------------|
| `spark/nano_grover_contracts.ads/.adb` | Bounded rails, oracle/diffusion, braid matrix, integrity mix |
| `spark/braid_chord_contracts.ads/.adb` | Chord frequency look-up contracts (flop-ROM dual) |

### Inverted DAE Graph (XML)

| File | Description |
|------|-------------|
| `graph/dae_inverted_graph.xml` | Tree-structured inversion of SPARK `{Pre} Cmd {Post}` into continuous DAE nodes/edges |

### Formal / Documentation

- `lean/NanoGroverMarkov.lean` — Zero-dependency Lean 4 Markov verification
- `docs/CIRCUIT_THEOREM.md` — Analytic energy & amplification theorem
- `docs/CROSS_DOMAIN_MAPPING.md` — SPARK ↔ Verilog-A ↔ Transistor mapping
- `docs/SPARK_TO_DAE_INVERSION.md` — Formal inversion principle and semiconductor bounds

## Cross-Domain Mapping (summary)

| SPARK Contract    | Verilog-A              | Transistor Equivalent      |
|-------------------|------------------------|----------------------------|
| Bounded Integer   | Voltage Rails          | Supply clamping            |
| State Invariant   | Steady-state nodal balance | Collector/drain equilibrium |
| Matrix Multiplier | VCVS / Gilbert cell    | Translinear loop           |
| Hash Integrity    | Non-linear mixing      | Exponential mixer          |

## License

- AGPLv3 (`LICENSE`)
- Component covenant: `LicenseRef-Sovereign-Leviathan-SL-AGPL3-001`
- All sources carry the SL-AGPL3-001 header.
