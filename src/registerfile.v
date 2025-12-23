`timescale 1ns / 1ps

/*
Name: Klay Adams
R-Number: R-11679660
Assignment: Project 2
*/

module registerfile( 
    input clk, reset, RL, //Input line declaration
    input [4:0] AA, BA, DA, //Input and Output addresses for the data in and busses out
    input [31:0] D, //Data input
    output [31:0] A, B, //Busses out
    output reg [31:0] test
    );
    
    reg [31:0] regbank [31:0]; //A bank of 32 registers each 32 bits in size
    
    always @(*) begin
        //regbank[1] <= 10;
        //regbank[2] <= 16;
        
        test <= regbank[31];
        
        //if(reset) for (integer i = 0; i < 32; i = i + 1) regbank[i] <= 0; //For loop used to loop through the register bank and reset the registers to 0
        if(RL == 1) regbank[DA] <= D; //If the register load signal (RL) goes high, then move the data from data input bus into the specified regisater location in the register bank
    end
        assign A = regbank[AA]; //For reading purposes assign the contents of the register at the given address in the bank  to the respective output databus
        assign B = regbank[BA]; //See 23
endmodule  
