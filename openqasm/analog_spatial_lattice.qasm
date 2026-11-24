// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.

// =====================================================================
// analog_spatial_lattice.qasm
// Spatial 2-qubit lattice with microwave / cross-resonance binding.
// Binds to spatial_grover_lattice.va
// =====================================================================

OPENQASM 3.0;
include "stdgates.inc";

pragma nano_grover.map "State Invariant" "Steady-state nodal balance" "Collector/drain equilibrium";
pragma nano_grover.map "Matrix Multiplier" "VCVS / Gilbert cell" "Translinear loop";

pragma nano_grover.bind "cr_gate"  "src/spatial_grover_lattice.va" "CTRCT_Diffusion";
pragma nano_grover.bind "collapse" "src/spatial_grover_lattice.va" "CTRCT_Oracle";

qubit[2] q;
bit[2]   c;

// Coupling parameters (from spatial_grover_lattice.va)
const float[64] DISTANCE   = 50.0e-6;   // 50 µm
const float[64] COUPLING_K = 1.0e-3;
const float[64] J_eff      = COUPLING_K / (DISTANCE * DISTANCE * DISTANCE);

// Initialise
h q[0];
h q[1];

// Cross-resonance interaction (analog: interaction_term on phases)
// HDL: q0_phase += interaction_term; q1_phase += interaction_term
rz(J_eff) q[0];
rz(J_eff) q[1];

// Optional amplitude inversion (falling edge of rf_q0 in VA)
x q[0];
x q[1];

// Collapse / measurement
c = measure q;
