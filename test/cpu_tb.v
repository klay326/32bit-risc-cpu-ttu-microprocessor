`timescale 1ns / 1ps

module cpu_tb();
    reg clk, rst; 
    
    cpu dut(.clk(clk),.rst(rst));
    
    initial begin
        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;
    end
    
    always begin
        clk = ~clk;
        #5;
    end   
endmodule
