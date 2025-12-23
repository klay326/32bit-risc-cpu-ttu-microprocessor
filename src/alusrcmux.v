`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R11679660
    Assignment: Project 6
*/

module alusrcmux (
  input [31:0] literal, //Literal  value fron instruction decoding
  input [31:0] regbdata, //The b bus data from the register file
  input wire alusrc, //Alu control signals for data switching
  output [31:0] b_bus //The output being sent to alu
);

assign b_bus = alusrc ? literal : regbdata; //Terinary logic to select between the two data sources

endmodule
