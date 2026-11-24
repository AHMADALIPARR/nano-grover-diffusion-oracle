// License-ID: SL-AGPL3-001
// Reversible conjunction of four external verification predicates.
// Predicates are computed classically; this circuit combines verdicts.

OPENQASM 3.0;
include "stdgates.inc";

input bit[4] checks;
qubit[4] constraints;
qubit[2] workspace;
qubit verdict;
bit result;

// Load classical predicate bits onto constraint qubits
for int i in [0:3] {
    if (checks[i] == 1) {
        x constraints[i];
    }
}

// Reversible AND-tree (uncomputed ancillae)
ccx constraints[0], constraints[1], workspace[0];
ccx constraints[2], constraints[3], workspace[1];
ccx workspace[0], workspace[1], verdict;

// Uncompute
ccx constraints[2], constraints[3], workspace[1];
ccx constraints[0], constraints[1], workspace[0];

result = measure verdict;
