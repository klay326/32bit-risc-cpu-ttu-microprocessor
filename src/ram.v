`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R-11679660
    Assignment: Project 4
*/

module ram(
    input clka, // Declare clock input signal
    input wea, // Declare write enable input signal
    input [31:0] addra, // Declare address input signal
    input [31:0] dina, // Declare data input signal
    output [0:31] douta // Declare data output signal
    );
    
// Xilinx IP usage with their instatntiation template      
    
mem_gen_ram U1 (
  .clka(clka),            // Input wire clka
  .wea(wea),              // Input wire [0 : 0] wea
  .addra(addra),          // Input wire [3 : 0] addra
  .dina(dina),            // Input wire [3 : 0] dina
  .douta(douta)          // Output wire [3 : 0] douta
);
endmodule
