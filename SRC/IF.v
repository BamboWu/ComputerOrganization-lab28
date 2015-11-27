`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:23:21 11/12/2009 
// Design Name: 
// Module Name:    IF 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module IF(clk, reset, Z, J, JR, PC_IFWrite, JumpAddr, 
          JrAddr, BranchAddr, Instruction_if,PC, NextPC_if);
    input clk;
    input reset;
    input Z;
    input J;
    input JR;
    input PC_IFWrite;
    input [31:0] JumpAddr;
    input [31:0] JrAddr;
    input [31:0] BranchAddr;
    output [31:0] Instruction_if;
    output [31:0] PC,NextPC_if;

// MUX for PC
    wire[31:0] PC_in;
    reg[1:0] sel_decoded;
    always@(*)
	    case({JR,J,Z})
		   3'b000: sel_decoded = 00;  /* PC=PC+4 */
		   3'b001: sel_decoded = 01;  /* Branch */
		   3'b010: sel_decoded = 10;  /* Jump */
		   3'b100: sel_decoded = 11;  /* Jump Register */
		   default:sel_decoded = 00;  /* default to next instruction */	
		endcase
    mux_4to1 #(.WIDTH(32)) mux_PC(.sel(sel_decoded),.in0(NextPC_if),.in1(BranchAddr),.in2(JumpAddr),.in3(JrAddr),.out(PC_in));
	
//PC REG

    dff #(.WIDTH(32))Program_Counter(.clk(clk&PC_IFWrite),.r(reset),.d(PC_in),.q(PC));
     
//Adder for NextPC

    adder_32bits adder_PC4(.a(PC),.b(32'd4),.ci(1'b0),.s(NextPC_if),.co());
  	
	  
//ROM
InstructionROM  InstructionROM(
	.addr(PC[7:2]),
	.dout(Instruction_if));
	
endmodule
