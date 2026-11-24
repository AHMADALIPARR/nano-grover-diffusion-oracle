// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.

// =====================================================================
// analog_grover_2q.qasm
// Analog-bound OpenQASM 3 circuit for 2-qubit Grover.
// Each gate is annotated with its HDL binding and SPARK contract.
// =====================================================================

OPENQASM 3.0;
include "stdgates.inc";

// ---- Cross-domain binding pragmas ---------------------------------
// #pragma nano_grover.bind  <openqasm_op>  <hdl_module>  <spark_contract>
// #pragma nano_grover.map   <spark>  <verilog_a>  <transistor>

pragma nano_grover.map "Bounded Integer" "Voltage Rails" "Supply clamping";
pragma nano_grover.map "State Invariant" "Steady-state nodal balance" "Collector/drain equilibrium";
pragma nano_grover.map "Matrix Multiplier" "VCVS / Gilbert cell" "Translinear loop";
pragma nano_grover.map "Hash Integrity" "Non-linear mixing" "Exponential mixer";

// HDL bindings
pragma nano_grover.bind "oracle"  "src/nano_grover_triple_iteration.va"  "CTRCT_Oracle";
pragma nano_grover.bind "diffuser" "src/nano_grover_triple_iteration.va" "CTRCT_Diffusion";
pragma nano_grover.bind "measure"  "rtl/quantum/q_braid_chord_rom.sv"    "CTRCT_Chord";

// ---- Qubit & classical registers ----------------------------------
qubit[2] q;
bit[2]   c;

// ---- Analog amplitude rail (maps Bounded Integer → Voltage Rails) --
// Soft constraint: amplitudes interpreted as voltages in [0, VDD]
const float[64] VDD = 1.8;
const float[64] VSS = 0.0;

// ---- Initial uniform superposition (Pre-condition charging) -------
// SPARK Pre: for all I => V(I) in Voltage_Rail
h q[0];
h q[1];

// ---- Grover iteration × 3  (matches nano_grover_triple_iteration) --
for int i in [0:2] {

    // Oracle: phase flip on |11⟩  (target = 3)
    // HDL : NDR cubic non-linearity on V3  (Hash Integrity → Exponential mixer)
    // SPARK: CTRCT_Oracle
    cz q[0], q[1];          // phase kick on |11⟩
    // analog annotation: I_NDR = (1/Rndr)*(-1.5*V3 + 0.5*V3^3/V0^2)

    // Diffuser: inversion about the mean
    // HDL : star-coupled mean bus + reflection  (State Invariant → nodal balance)
    // SPARK: CTRCT_Diffusion
    h q[0];
    h q[1];
    x q[0];
    x q[1];
    cz q[0], q[1];
    x q[0];
    x q[1];
    h q[0];
    h q[1];
    // analog annotation: V_k := 2*Vbar - V_k   within Δt window
}

// ---- Measurement / collapse ---------------------------------------
// HDL : collapse_cmd path in nano_grover_triple_iteration.va
//       + q_braid_chord_rom.sv measure_en
c = measure q;
