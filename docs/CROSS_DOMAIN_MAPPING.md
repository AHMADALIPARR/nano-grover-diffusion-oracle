# Cross-Domain Mapping

| SPARK Contract          | Verilog-A                        | Transistor Equivalent      |
|-------------------------|----------------------------------|----------------------------|
| Bounded Integer         | Voltage Rails                    | Supply clamping            |
| State Invariant         | Steady-state nodal balance       | Collector/drain equilibrium|
| Matrix Multiplier       | VCVS / Gilbert cell              | Translinear loop           |
| Hash Integrity          | Non-linear mixing                | Exponential mixer          |

## Flop Algorithm → Quantum Extension

The `braid_chord_flop_rom` module is the source-of-truth sequential element.
Its `always_ff` pattern is lifted into the quantum domain by:

1. Replacing scalar frequency words with amplitude-encoded 2-qubit state vectors.
2. Interpreting the case-select as an oracle target index.
3. Adding a measurement / collapse path that projects back to classical bits.

Resulting modules:

- `rtl/quantum/q_braid_chord_rom.sv` — amplitude look-up from chord eigenvalues
- `rtl/quantum/q_grover_flop_stage.sv` — single Grover iteration in flip-flop registers

## Trigonometric Processor Family

| Module                      | Domain   | Purpose                                      |
|-----------------------------|----------|----------------------------------------------|
| `trig_processor`            | VA / SV  | Simple sin/cos + boundary checks             |
| `trig_braid_processor`      | VA / SV  | Full φ-weighted braid matrix ρ(σ₁) + rails   |
| `braid_trig_processor`      | VA / SV  | Minimal Metatron φ processor                 |
