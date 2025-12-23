`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R11679660
    Assignment: Project 3
*/

module alu(
    input clk, reset, // Input line declarations that drive the module
    input [31:0] a_bus, b_bus, // 32 bit wide input busses containing the data to operate on
    input [4:0] opcode, // 5 bit wide opcode selection bus to pick each alu function
    output reg [31:0] out_bus, // 32 bit wide output bus containing the result post operation
    output z // Flag declaration bits for zero bit 
    );
    
    // Parameters used to declare each opcode instruction to a respective hex number indication the operation to be performed     
    parameter LD = 5'h01; //Load Opcode
    parameter ST = 5'h02; //Store opcode
    parameter ADD = 5'h03; //Add opcode
    parameter SUB = 5'h04; //Subtraction opcode
    parameter AND = 5'h05; //And opcode
    parameter OR = 5'h06; //Or opcode
    parameter XOR = 5'h07; //Xor opcode
    parameter NOT = 5'h08; //Not opcode
    parameter SL = 5'h09; //Shift left opcode
    parameter SR = 5'h0A; //Shift right opcode


    assign z = (out_bus == 0); // Zero flag that checks if any of the output bus results in a zero
  
    always @(*) begin
        if(reset) begin
            out_bus <= 0; // A simple result to make sure the output bus is 0 before starting and acts as a catch all if the case statement has issues
        end
        // Case statment acting as an opcode selector to handle choosing which operation to perform
        case(opcode)
            LD: begin out_bus <= b_bus; end // A simple data pass through load operation utilizing the a_bus
            ST: begin out_bus <= b_bus; end
            ADD: begin out_bus <= a_bus + b_bus; end // Performs an add operation and concatonates an extra fake 33rd bit to indicate if a carry operation is caused by the 32 bit operations carry outside the scope of the registers
            SUB: begin out_bus <= a_bus - b_bus; end // Performs a sub operation and concatonates an extra fake 33rd bit to indicate if a carry operation is caused by the 32 bit operations carry outside the scope of the registers
            NOT: begin out_bus <= ~a_bus; end // An inversion operation that nots the a_bus signal
            OR: begin out_bus <= a_bus | b_bus; end // Performs bitwise or operation between the 2 input busses
            XOR: begin out_bus <= a_bus ^ b_bus; end // Performs a bitwise exclusive or operation between the 2 input busses
            AND: begin out_bus <= a_bus & b_bus; end // Performs a bitwise and operation between the 2 input busses
            SR: begin out_bus <= a_bus >> b_bus; end // Performs a bitshift right on the input bus a by the number specifed in bus b
            SL: begin out_bus <= a_bus << b_bus; end // Performs a bitshift left on the input bus a by the number specifed in bus b
            default: begin out_bus <= 0; end // Acts as a default condition to makesure the output bus is 0 when an operation isnt specified
        endcase
    end
endmodule
