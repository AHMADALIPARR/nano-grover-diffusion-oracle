// License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference
// SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
// Main project policy: LICENSES/LicenseRef-Sovereign-Leviathan-SL-AGPL3-001.txt.
// Existing file, component and third-party notices and grants are preserved.

// =====================================================================
// trig_processor.sv
// Simple sin/cos trigonometric processor with boundary checks.
// Digital dual of trig_processor.va — fixed-point / IEEE-754 friendly.
// =====================================================================

module trig_processor #(
    parameter int WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             valid_in,
    input  logic [WIDTH-1:0] theta_in,   // IEEE-754 single or fixed-point angle
    output logic             valid_out,
    output logic [WIDTH-1:0] sin_out,
    output logic [WIDTH-1:0] cos_out,
    output logic             bound_err   // set when |theta| > π domain
);

    // π in IEEE-754 single: 32'h40490FDB
    localparam logic [31:0] PI_F32 = 32'h40490FDB;

    // Simple registered pass-through with domain flag.
    // Real sin/cos evaluation is left to downstream DSP or LUT;
    // this module enforces the SPARK-style boundary invariant.

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            sin_out   <= '0;
            cos_out   <= '0;
            bound_err <= 1'b0;
        end else if (valid_in) begin
            valid_out <= 1'b1;
            // Placeholder identity mapping; replace with CORDIC / LUT later
            sin_out   <= theta_in;
            cos_out   <= theta_in;
            // Domain check against π (unsigned magnitude comparison on exponent/mantissa)
            bound_err <= (theta_in[30:0] > PI_F32[30:0]);
        end else begin
            valid_out <= 1'b0;
            bound_err <= 1'b0;
        end
    end

endmodule
