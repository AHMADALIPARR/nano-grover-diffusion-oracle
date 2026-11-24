// License-ID: SL-AGPL3-001
// Skeleton OpenQASM for a quantum linear-system verification step.
// Encodes the Hermitian embedding residual check at the gate level
// (state preparation and controlled rotations are placeholders).

OPENQASM 3.0;
include "stdgates.inc";

// Register layout (illustrative, small system n=2 → H is 4×4)
qubit[4] sys;      // Hermitian embedding space
qubit[1] anc;      // phase-estimation / residual ancilla
bit[1]   flag;

// --- State preparation of |b⟩ (placeholder) ---
h sys[0];
h sys[1];

// --- Controlled unitary e^{iHt} fragments (placeholders) ---
// Real implementation lowers a Hamiltonian simulation of the
// embedded matrix H = [0 A; A† 0] produced by numerical/Hermitian.jl
cz sys[0], sys[2];
cz sys[1], sys[3];

// --- Residual observable sample ---
h anc[0];
cz anc[0], sys[0];
h anc[0];
flag[0] = measure anc[0];
