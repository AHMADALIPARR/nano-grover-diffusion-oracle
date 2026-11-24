// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.

// =====================================================================
// analog_q_grover_flop.qasm
// OpenQASM binding to the flip-flop Grover stage
// (rtl/quantum/q_grover_flop_stage.sv) and chord ROM.
// =====================================================================

OPENQASM 3.0;
include "stdgates.inc";

pragma nano_grover.map "Bounded Integer" "Voltage Rails" "Supply clamping";
pragma nano_grover.map "State Invariant" "Steady-state nodal balance" "Collector/drain equilibrium";
pragma nano_grover.map "Hash Integrity" "Non-linear mixing" "Exponential mixer";

pragma nano_grover.bind "flop_oracle"   "rtl/quantum/q_grover_flop_stage.sv" "CTRCT_Oracle";
pragma nano_grover.bind "flop_diffuse"  "rtl/quantum/q_grover_flop_stage.sv" "CTRCT_Diffusion";
pragma nano_grover.bind "chord_rom"     "rtl/braid_chord_flop_rom.sv"        "CTRCT_Chord";

qubit[2] q;
bit[2]   c;

// Target select (matches chord_sel / target port)
int[2] target = 3;   // |11⟩

// Uniform start (flop reset state 0.5 on each amplitude register)
h q[0];
h q[1];

// One flop-stage Grover iteration (iterate_en pulse)
// Oracle: IEEE-754 sign-bit flip on target amplitude register
cz q[0], q[1];

// Diffusion: structural mean inversion (amp registers)
h q[0];
h q[1];
x q[0];
x q[1];
cz q[0], q[1];
x q[0];
x q[1];
h q[0];
h q[1];

// Measurement projects back to classical bits (measure_en)
c = measure q;
