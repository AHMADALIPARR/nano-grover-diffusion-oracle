// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
// Existing file, component and third-party notices and grants are preserved.

// =====================================================================
// q_braid_chord_rom.sv
// Quantum-circuit extension of braid_chord_flop_rom.
// Maps classical chord eigenvalues into a 2-qubit computational basis
// amplitude look-up (amplitude-encoded frequencies).
// =====================================================================

module q_braid_chord_rom (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  chord_sel,     // classical select
    input  logic        measure_en,    // collapse enable
    output logic        valid_out,
    output logic [31:0] amp_q0,        // |0⟩ / |1⟩ amplitude (IEEE-754)
    output logic [31:0] amp_q1,
    output logic [1:0]  measured       // post-collapse classical bits
);

    // Pre-computed amplitude pairs corresponding to the three chord tones.
    // Root  → equal superposition scaled by 200 Hz eigenvalue weight
    // Third → weighted toward |01⟩ / |10⟩
    // Fifth → weighted toward |11⟩

    logic [31:0] a0, a1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a0        <= 32'h00000000;
            a1        <= 32'h00000000;
            valid_out <= 1'b0;
            measured  <= 2'b00;
        end else begin
            valid_out <= 1'b1;
            unique case (chord_sel)
                2'b00: begin // Root ~200 Hz → balanced
                    a0 <= 32'h3F3504F3; // ≈ 0.7071
                    a1 <= 32'h3F3504F3;
                end
                2'b01: begin // Third ~280 Hz
                    a0 <= 32'h3F000000; // 0.5
                    a1 <= 32'h3F5A827A; // ≈ 0.8660
                end
                2'b10: begin // Fifth ~351 Hz
                    a0 <= 32'h3EAAAAAB; // ≈ 0.333
                    a1 <= 32'h3F55C100; // ≈ 0.833
                end
                default: begin
                    a0        <= 32'h00000000;
                    a1        <= 32'h00000000;
                    valid_out <= 1'b0;
                end
            endcase

            // Measurement / collapse (classical projection)
            if (measure_en) begin
                // Simple threshold on magnitude of a1
                measured[0] <= (a0[30:0] > a1[30:0]);
                measured[1] <= (a1[30:0] > 32'h3F000000);
            end
        end
    end

    assign amp_q0 = a0;
    assign amp_q1 = a1;

endmodule
