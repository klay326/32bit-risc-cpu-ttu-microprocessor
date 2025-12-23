`timescale 1ns / 1ps

/*
    Name: Klay Adams
    R-Number: R11679660
    Assignment: Project 5
*/

module instructiondecoder(
    input clk, rst,
    input [48:0] instruction, //ROM Data
    output reg [4:0] alu_oper, registerdst_addr, registerasrc_addr, registerbsrc_addr, aluormem, alusrc, //5 Bit control outputs
    output reg [31:0] literal_value, //32 Bit literal value out bus
    output reg register_load, ram_wr //1 Bit output control flags
    );
    
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
    parameter BZ = 5'h10; //Branch if zero opcode
    parameter BNZ = 5'h11; //Branch if not zero opcode
    parameter BRA = 5'h12; //Unconditional branch opcode
    
    parameter immediate = 3'b00; //Immediate addressing mode
    parameter direct = 3'b01; //Direct addressing mode
    parameter register = 3'b10; //Register addresing mode
    
    parameter selectalu = 3'b00; //Select alu mux
    parameter selectmem =  3'b01; //Select mem mux

    parameter regALUsrc = 3'b00; //Register alu src mux
    parameter literalALUsrc = 3'b01; //Literal alu src mux

    parameter noUse = 3'b00; //A general zero used for flags not in use

    parameter loadreg = 3'b01; //Register load enable signal
    parameter ram_write = 3'b01; //Ram write enable signal

    wire [4:0] opcode; //Instruction register bit assignments:
    wire [1:0] adressing_mode;
    wire [4:0] source;
    wire [4:0] dest;
    wire [31:0] literal_source;
    
    assign opcode = instruction [48:44]; //Bit assignments parsing the instruction data:
    assign adressing_mode = instruction [43:42];
    assign source = instruction [41:37];
    assign dest = instruction [36:32];
    assign literal_source = instruction [31:0];
    
    always @(*) begin
        if(rst) begin //Reset condition to zero out all control words:
            alu_oper <= noUse;
            registerdst_addr <= noUse;
            registerasrc_addr <= noUse;
            registerbsrc_addr <= noUse;
            aluormem <= noUse;
            alusrc <= noUse;
            literal_value <= noUse;
            register_load <= noUse;
            ram_wr <= noUse;
        end
        case(opcode)
            LD: begin
                case(adressing_mode)
                    immediate: begin //Load immediate adressing mode specific controls
                        aluormem <= selectalu;
                        register_load <= loadreg;
                    end
                    direct: begin //Load direct addressing mode specific contorl signals
                        aluormem <= selectmem;
                        register_load <= loadreg;
                    end
                endcase //Generic to load operation control signals
                alusrc <= literalALUsrc;
                registerdst_addr <= dest;
                registerasrc_addr <= noUse;
                registerbsrc_addr <= literal_source;
                alu_oper <= LD;
                literal_value <= literal_source;
                ram_wr <= noUse;
            end
            ST: begin //General control signals for store operations
                alu_oper <= ST;
                registerdst_addr <= noUse;
                registerasrc_addr <= noUse;
                registerbsrc_addr <= source;
                aluormem <= selectmem;
                alusrc <= literalALUsrc;
                literal_value <= literal_source;
                register_load <= noUse;
                ram_wr <= ram_write;
            end
            ADD: begin 
                case(adressing_mode)
                    immediate: begin 
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin 
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase 
                alu_oper <= ADD;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse;
            end
            SUB: begin 
                case(adressing_mode)
                    immediate: begin //Subtraction immediate addressing mode specific contorl signals 
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin //Register addressing mode specific contorl signals
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase //General subtraction contorl signals
                alu_oper <= SUB;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse; 
            end
            AND: begin 
                case(adressing_mode)
                    immediate: begin //And immediate addressing mode control signals 
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin //And register addressing mode control signals
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase //General and contorl signals
                alu_oper <= AND;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse;  
            end
            OR: begin 
                case(adressing_mode)
                    immediate: begin //Or immediate addressing mode control signals
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin //Or register addressing mode control signals
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase
                alu_oper <= OR; //General or operation control signals
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse;  
            end
            XOR: begin 
                case(adressing_mode)
                    immediate: begin //Xor immediate addressing mode control signals
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin //Xor register addressing mode contorl signals
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase //General xor control signals
                alu_oper <= XOR;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse;  
            end
            NOT: begin //Not Control signals
                alu_oper <= NOT;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                registerbsrc_addr <= noUse;
                aluormem <= selectalu;
                alusrc <= regALUsrc;
                literal_value <= noUse;
                register_load <= loadreg;
                ram_wr <= noUse;
            end
            SL: begin 
                case(adressing_mode)
                    immediate: begin //Shift left immediate addressing mode control signals
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin //Shift left register addressing mode control signals
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase //General shift left control signals
                alu_oper <= SL;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse; 
            end
            SR: begin 
                case(adressing_mode)
                    immediate: begin //Shift right immediate addressing mode control signals
                        registerbsrc_addr <= noUse;
                        alusrc <= literalALUsrc;
                        literal_value <= literal_source;
                    end
                    register: begin //Shift right register control signals
                        registerbsrc_addr <= literal_source;
                        alusrc <= regALUsrc;
                        literal_value <= noUse;
                    end
                endcase //Generic shift right control signals
                alu_oper <= SR;
                registerdst_addr <= dest;
                registerasrc_addr <= source;
                aluormem <= selectalu;
                register_load <= loadreg;
                ram_wr <= noUse; 
            end
        endcase
    end
endmodule
