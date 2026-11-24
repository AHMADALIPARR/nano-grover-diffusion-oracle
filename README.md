# Nano-Grover Diffusion & Oracle Iteration Circuit

Formal synthesis and verification of analog **Nano-Grover** circuits, trigonometric braid processors, SPARK contracts, Analog OpenQASM, and SPICE→OpenQASM verification.

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

### Digital RTL (SystemVerilog)

| File | Description |
|------|-------------|
| `rtl/braid_chord_flop_rom.sv` | Source-of-truth flip-flop chord ROM |
| `rtl/trig_processor.sv` / `trig_braid_processor.sv` / `braid_trig_processor.sv` | Digital trig duals |
| `rtl/quantum/q_braid_chord_rom.sv` | Amplitude-encoded 2-qubit look-up |
| `rtl/quantum/q_grover_flop_stage.sv` | Grover iteration in flop registers |

### Analog OpenQASM (bound to HDL)

| File | Description |
|------|-------------|
| `openqasm/analog_grover_2q.qasm` | 2-qubit Grover ×3 |
| `openqasm/analog_braid_trig.qasm` | φ-braid rotation |
| `openqasm/analog_spatial_lattice.qasm` | Spatial CR lattice |
| `openqasm/analog_q_grover_flop.qasm` | Flop-stage Grover |
| `openqasm/bindings/hdl_bind_table.md` | Binding table |

### Ada SPARK / DAE Graph

| Path | Description |
|------|-------------|
| `spark/` | Bounded rails, oracle/diffusion, braid, chord contracts |
| `graph/dae_inverted_graph.xml` | Hierarchical SPARK→DAE inversion graph |

### spice-qasm-verifier (SPICE → MNA → OpenQASM)

| Path | Role |
|------|------|
| `spice-qasm-verifier/netlists/` | RC, RLC, MOSFET reference decks |
| `spice-qasm-verifier/parser/` | Haskell netlist AST |
| `spice-qasm-verifier/semantics/` | Lean 4 Kirchhoff, devices, MNA, stability |
| `spice-qasm-verifier/contracts/` | WhyML stamp & discretization contracts |
| `spice-qasm-verifier/numerical/` | Julia MNA / Hermitian embed / residual |
| `spice-qasm-verifier/quantum/` | OpenQASM predicates & linear-system circuits |
| `spice-qasm-verifier/calibration/` | OpenPulse control fragments |
| `spice-qasm-verifier/verification/` | Refinement & error-bound Lean modules |

Core refinement:

```text
Accept_QASM(N)  ⟹  Valid_ε(N)
```

### Formal / Documentation

- `lean/NanoGroverMarkov.lean` — Zero-dependency Lean 4 Markov verification
- `docs/CIRCUIT_THEOREM.md`, `docs/CROSS_DOMAIN_MAPPING.md`, `docs/SPARK_TO_DAE_INVERSION.md`

## Cross-Domain Mapping

| SPARK Contract | Verilog-A | Transistor Equivalent |
|----------------|-----------|------------------------|
| Bounded Integer | Voltage Rails | Supply clamping |
| State Invariant | Steady-state nodal balance | Collector/drain equilibrium |
| Matrix Multiplier | VCVS / Gilbert cell | Translinear loop |
| Hash Integrity | Non-linear mixing | Exponential mixer |

## License

AGPLv3 + `LicenseRef-Sovereign-Leviathan-SL-AGPL3-001`
