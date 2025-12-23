`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R-11679660
    Assignment: Project 4
*/

module rom(
    input clka, // Declare clock input signal
    input [3:0] addra, // Declare address input signal
    output [48:0] douta // Declare data output signal
    );

// Xilinx IP usage with their instatntiation template  
    
mem_gen_rom U1 (
  .clka(clka),            // Input wire clka
  .addra(addra),          // Input wire [3 : 0] addra
  .douta(douta)          // Output wire [3 : 0] douta
);

endmodule
