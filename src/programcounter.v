`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R11679660
    Assignment: Project 6
*/

module programcounter(
    input clk, rst, z, //Clock and reset input signals and the z flag from the alu
    output [48:0] romout //Outputs the rom data out to be sent to the instruction decoder
    );
    
    parameter BZ = 5'h10; //Branch if zero opcode
    parameter BNZ = 5'h11; //Branch if not zero opcode
    parameter BRA = 5'h12; //Unconditional branch opcode
    
    reg lastz; //Flag holding the previous instructions z flag value
    reg [5:0] pc; //Program counter register to hold rom address
    reg [3:0] counter; //Counter to delay the incrmeenting of the program counter 

    mem_gen_rom U1 (.clka(clk),.addra(pc),.douta(romout)); //Rom module usage and instantiation
    
    always@ (posedge clk) begin
        if (rst) begin
            pc <= 0; //Resets the program counter on boot
        end
        if (counter < 4) //Counter delay to slow down program counter incrmenting
            counter <= counter + 1;
        else begin
            counter = 0; //Resets counter
            case (romout[48:44]) //Case stamenet checking the opcode bits of the instruction for any containing jumps
                BZ: begin 
                    if (lastz) begin //Checks the z flag to handle the branch if zero condition
                        pc <= romout[4:0]; //Sets the pc value to the immediate value in the instruction
                    end else begin
                        pc <= pc + 1; //Increments PC to next instruction normally
                    end
                end
                BNZ: begin 
                    if (~lastz) begin //Checks if the z flag is not set to handle the not zero condition
                        pc <= romout[4:0]; //Sets the pc value to the immediate value in the instruction
                    end else begin
                        pc <= pc + 1; //Increments PC to next instruction normally
                    end
                end 
                BRA: begin
                    pc <= romout[4:0]; //Sets the pc value to the immediate value in the instruction
                end
                default: begin
                    pc <= pc + 1; //Increments PC to next instruction normally
                end
            endcase
            lastz <= z; //Keeps the previous z flag value form the last instruction
        end
    end
endmodule    
