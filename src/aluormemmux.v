`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R11679660
    Assignment: Project 6
*/

module aluormemmux (
  input [31:0] aluout, //Alu output bus
  input [31:0] ramout, //The ram data out
  input wire aluormem, //Selection signal between the data
  output [31:0] regdatain //OUtput being sent into the register file
);

assign regdatain = aluormem ? ramout : aluout; //Terinary logic to select between the data sources to the register file

endmodule
