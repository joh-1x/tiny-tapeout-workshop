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
  //assign uio_out = 8'h00;
  assign uio_oe  = 8'hff; // enable all IOs as outputs

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, uio_in, 1'b0};


  reg state, next_state;
  localparam Start = 1'b0;
  localparam Work = 1'b1;

  reg [31:0] value;
  wire [31:0] next_value;
  xorshift32 prng (
    .value(value),
    .next_value(next_value)
  );
  wire [31:0] mixed_value;
  assign mixed_value = value ^ (value >> 11) ^ (value >> 21);

  //assign uio_out = value[31:24];
  assign uio_out = mixed_value[7:0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= Start;
        value <= 0;
    end else begin
        state <= next_state;
        case (state)
          Start: begin
            value[7:0] <= ui_in; // Load seed from input
            value[31:8] <= 0; // Clear upper bits
          end
          Work: begin
            value <= next_value;
          end
        endcase
    end
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



module xorshift32 (
    input  wire [31:0] value,
    output reg [31:0] next_value
);
  reg [31:0] x;
  always @(*) begin
    x = value;
    x = x ^ (x << 13);
    x = x ^ (x >> 17);
    next_value = x ^ (x << 5);
  end
endmodule