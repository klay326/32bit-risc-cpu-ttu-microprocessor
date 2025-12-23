`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R11679660
    Assignment: Project 6
*/

module cpu(
    input clk, rst //Input control lines for all driving signals for clock and reset form the testbench
    );
    
    wire [48:0] romtodecode; //Wire connecting the output of the rom to the instruction decoder
    wire [4:0] alu_oper, registerdst_addr, registerasrc_addr, registerbsrc_addr, aluormem, alusrc;  //Wires connecting the parsed info from the instruction decoder to other modules
    wire register_load, ram_wr, zflag; //1 Bit id output control flags
    wire [31:0] A, B, b_bus, out_bus, regdatain, resultwire, ramwire, literal_value; //32 Bit data wires
    
    programcounter pc(.clk(clk),.rst(rst),.z(zflag),.romout(romtodecode)); //Program counter instantiation
    instructiondecoder id(.clk(clk), .rst(rst), .instruction(romtodecode), .alu_oper(alu_oper), .registerdst_addr(registerdst_addr), .registerasrc_addr(registerasrc_addr), .registerbsrc_addr(registerbsrc_addr), .aluormem(aluormem), .alusrc(alusrc), .literal_value(literal_value), .register_load(register_load), .ram_wr(ram_wr)); //Instruction decoder instantiation
    alu alu(.clk(clk), .reset(rst), .a_bus(A), .b_bus(b_bus), .opcode(alu_oper), .out_bus(out_bus),.z(zflag)); // Alu module instantiation
    registerfile regfile(.clk(clk),.reset(rst),.RL(register_load),.AA(registerasrc_addr),.BA(registerbsrc_addr),.DA(registerdst_addr),.D(regdatain),.A(A),.B(B),.test(resultwire)); //Register file module instantiation
    alusrcmux mux1(.literal(literal_value),.alusrc(alusrc),.regbdata(B),.b_bus(b_bus)); //First of 2 muxes instantion controlling what data is the source for the alu
    aluormemmux mux2(.aluout(out_bus),.aluormem(aluormem),.regdatain(regdatain),.ramout(ramwire)); //Second mux instantiation controlling weither the alu or ram data is sent to the register file
    ram rammodule(.clka(clk),.wea(ram_wr),.addra(out_bus),.dina(B),.douta(ramwire)); //Ram module instantiation
endmodule
