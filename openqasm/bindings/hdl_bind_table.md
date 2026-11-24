# Analog OpenQASM ↔ HDL Binding Table

## Cross-Domain Mapping (source of truth)

| SPARK Contract      | Verilog-A                      | Transistor Equivalent            |
|---------------------|--------------------------------|----------------------------------|
| Bounded Integer     | Voltage Rails                  | Supply clamping                  |
| State Invariant     | Steady-state nodal balance     | Collector/drain equilibrium      |
| Matrix Multiplier   | VCVS / Gilbert cell            | Translinear loop                 |
| Hash Integrity      | Non-linear mixing              | Exponential mixer                |

## Circuit → HDL Bindings

| OpenQASM File                    | Primary Gate / Block | HDL Module                              | SPARK Contract   |
|----------------------------------|----------------------|-----------------------------------------|------------------|
| `analog_grover_2q.qasm`           | oracle (cz)          | `src/nano_grover_triple_iteration.va`   | CTRCT_Oracle     |
| `analog_grover_2q.qasm`           | diffuser (H-X-CZ-X-H)| `src/nano_grover_triple_iteration.va`   | CTRCT_Diffusion  |
| `analog_grover_2q.qasm`           | measure              | `rtl/quantum/q_braid_chord_rom.sv`      | CTRCT_Chord      |
| `analog_braid_trig.qasm`          | braid_rot (U)        | `src/trig_braid_processor.va`           | CTRCT_Braid      |
| `analog_braid_trig.qasm`          | braid_rot (U)        | `rtl/trig_braid_processor.sv`           | CTRCT_Braid      |
| `analog_spatial_lattice.qasm`     | cr_gate (rz)         | `src/spatial_grover_lattice.va`         | CTRCT_Diffusion  |
| `analog_spatial_lattice.qasm`     | collapse             | `src/spatial_grover_lattice.va`         | CTRCT_Oracle     |

## Pragma Conventions

```
#pragma nano_grover.map   "<SPARK>"  "<Verilog-A>"  "<Transistor>"
#pragma nano_grover.bind  "<op_name>"  "<hdl_path>"  "<contract_id>"
```

- `map` records the four canonical cross-domain rows.
- `bind` attaches a concrete OpenQASM operation to an HDL source and a SPARK contract node in `graph/dae_inverted_graph.xml`.
