// License-ID: SL-AGPL3-001
// OpenPulse-style calibration fragment for analog control hardware.
// Used when the circuit under test is part of quantum-control electronics.

OPENQASM 3.0;

cal {
    // External waveform library would be declared here
    // waveform drive_wf = ...;
}

defcal rz(angle[20] theta) $0 {
    // Placeholder pulse definition
    // play drive_wf, frame0;
}

defcal measure $0 -> bit {
    bit b;
    // capture / discriminate
    return b;
}
