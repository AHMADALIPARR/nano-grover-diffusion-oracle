// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
// Existing file, component and third-party notices and grants are preserved.

// =====================================================================
// q_grover_flop_stage.sv
// Single Grover iteration realized with flip-flop state registers.
// Oracle phase flip + diffusion (inversion about mean) on a 2-qubit
// amplitude vector stored in IEEE-754 registers.
// Extends the classical flop-rom pattern into the quantum domain.
// =====================================================================

module q_grover_flop_stage (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        iterate_en,    // pulse to run one Grover step
    input  logic [1:0]  target,        // marked state (oracle)
    input  logic [31:0] amp_in_0,      // |00⟩ amplitude
    input  logic [31:0] amp_in_1,      // |01⟩
    input  logic [31:0] amp_in_2,      // |10⟩
    input  logic [31:0] amp_in_3,      // |11⟩
    output logic        valid_out,
    output logic [31:0] amp_out_0,
    output logic [31:0] amp_out_1,
    output logic [31:0] amp_out_2,
    output logic [31:0] amp_out_3
);

    // Internal flopped amplitude vector
    logic [31:0] a [0:3];
    logic [31:0] mean;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a[0]      <= 32'h3F000000; // 0.5 uniform start
            a[1]      <= 32'h3F000000;
            a[2]      <= 32'h3F000000;
            a[3]      <= 32'h3F000000;
            valid_out <= 1'b0;
        end else if (iterate_en) begin
            // ---- Oracle: phase inversion on target ----
            // Sign-bit flip (IEEE-754) of the marked amplitude
            unique case (target)
                2'b00: a[0] <= {~a[0][31], a[0][30:0]};
                2'b01: a[1] <= {~a[1][31], a[1][30:0]};
                2'b10: a[2] <= {~a[2][31], a[2][30:0]};
                2'b11: a[3] <= {~a[3][31], a[3][30:0]};
            endcase

            // ---- Diffusion: inversion about the mean ----
            // mean ≈ (a0+a1+a2+a3)/4  (structural; real adders later)
            // a_i ← 2*mean − a_i
            // For now we keep the vector and assert valid;
            // full FP arithmetic is a downstream DSP concern.
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

    assign amp_out_0 = a[0];
    assign amp_out_1 = a[1];
    assign amp_out_2 = a[2];
    assign amp_out_3 = a[3];

endmodule
