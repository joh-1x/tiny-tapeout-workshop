/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_joh1x_prng (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = 8'h00;
  assign uio_out = 8'h00;
  assign uio_oe  = 8'hff; // enable all IOs as outputs

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, uio_in, 1'b0};


  reg state, next_state;
  localparam Start = 1'b0;
  localparam Work = 1'b1;

  always @(posedge clk) begin //or negedge rst_n) begin
    //if (!rst_n) begin
    //  state <= Start;
    //end else begin
    //end
    state <= next_state;
  end

  always @(*) begin
    case (state)
      Start: begin
        next_state = Work;
      end
      Work: begin
        next_state = Work;
      end
      default: next_state = Start;
    endcase
  end
endmodule
