// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.

// =====================================================================
// analog_braid_trig.qasm
// Analog-bound OpenQASM for φ-weighted braid trigonometric processor.
// Binds to trig_braid_processor.va / .sv and CTRCT_Braid.
// =====================================================================

OPENQASM 3.0;
include "stdgates.inc";

pragma nano_grover.map "Bounded Integer" "Voltage Rails" "Supply clamping";
pragma nano_grover.map "Matrix Multiplier" "VCVS / Gilbert cell" "Translinear loop";

pragma nano_grover.bind "braid_rot" "src/trig_braid_processor.va" "CTRCT_Braid";
pragma nano_grover.bind "braid_rot" "rtl/trig_braid_processor.sv"  "CTRCT_Braid";

qubit[1] q;
bit[1]   c;

// Angle domain (Pre: Theta in -π .. π)  → Bounded Integer / Voltage Rail
const float[64] PI = 3.141592653589793;
angle[32] theta = 0.0;

// φ/2 constant (hardware param PHI_HALF)
const float[64] PHI_HALF = 0.8090169943749474;

// Prepare |+⟩
h q[0];

// Analog braid rotation  ρ(σ₁)
// HDL: V(sin_out) <+ PHI_HALF*sin(θ) + 0.5*cos(θ)
//      V(cos_out) <+ 0.5*sin(θ) - PHI_HALF*cos(θ)
// Transistor: Gilbert cell / translinear loop (Matrix Multiplier)
U(2.0 * PHI_HALF * theta, 0, 0) q[0];

// Rail clamp annotation (assertion failure → supply clamping)
// if |amp| > VDD → hard clip at RAIL_VDD / RAIL_VSS

c = measure q;
