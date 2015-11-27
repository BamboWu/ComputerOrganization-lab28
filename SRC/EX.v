`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:30:20 11/12/2009 
// Design Name: 
// Module Name:    EX 
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
module EX(RegDst_ex, ALUCode_ex, ALUSrcA_ex, ALUSrcB_ex, Imm_ex, Sa_ex, RsAddr_ex, RtAddr_ex, RdAddr_ex,
          RsData_ex, RtData_ex, RegWriteData_wb, ALUResult_mem, RegWriteAddr_wb, RegWriteAddr_mem, 
		  RegWrite_wb, RegWrite_mem, RegWriteAddr_ex, ALUResult_ex, MemWriteData_ex, ALU_A, ALU_B);
    input RegDst_ex;
    input [4:0] ALUCode_ex;
    input ALUSrcA_ex;
    input ALUSrcB_ex;
    input [31:0] Imm_ex;
    input [31:0] Sa_ex;
    input [4:0] RsAddr_ex;
    input [4:0] RtAddr_ex;
    input [4:0] RdAddr_ex;
    input [31:0] RsData_ex;
    input [31:0] RtData_ex;
    input [31:0] RegWriteData_wb;
    input [31:0] ALUResult_mem;
    input [4:0] RegWriteAddr_wb;
    input [4:0] RegWriteAddr_mem;
    input RegWrite_wb;
    input RegWrite_mem;
    output [4:0] RegWriteAddr_ex;
    output [31:0] ALUResult_ex;
    output [31:0] MemWriteData_ex;
    output [31:0] ALU_A;
    output [31:0] ALU_B;

//forwarding
	wire[1:0] ForwardA,ForwardB;

	assign ForwardA[0] = RegWrite_wb && (RegWriteAddr_wb!=5'd0) &&  /* 2nd data hazard */
	                     (RegWriteAddr_mem~=RsAddr_ex) && (RegWriteAddr_wb==RsAddr_ex);
	assign ForwardA[1] = RegWrite_mem && (RegWriteAddr_mem!=5'd0) &&
	                     (RegWriteAddr_mem==RsAddr_ex);             /* 1st data hazard */

	assign ForwardB[0] = RegWrite_wb && (RegWriteAddr_wb!=5'd0) &&  /* 2nd data hazard */
	                     (RegWriteAddr_mem~=RtAddr_ex) && (RegWriteAddr_wb==RtAddr_ex);
	assign ForwardB[1] = RegWrite_mem && (RegWriteAddr_mem!=5'd0) &&
	                     (RegWriteAddr_mem==RtAddr_ex);             /* 1st data hazard */
						 
//MUX for A
    
	reg[31:0] ALU_A_temp;
    mux_4to1 #(.WIDTH(32)) mux_A(.sel(ForwardA),
	                             .in0(RsData_ex),.in1(RegWriteData_wb),
								 .in2(ALUResult_mem),.in3(32'd0),.out(ALU_A_temp));

//MUX for B

	reg[31:0] ALU_B_temp;
    mux_4to1 #(.WIDTH(32)) mux_B(.sel(ForwardB),
	                             .in0(RtData_ex),.in1(RegWriteData_wb),
								 .in2(ALUResult_mem),.in3(32'd0),.out(ALU_B_temp));
	assign MemWriteData_ex = ALU_B_temp[31:0];
 
//MUX for ALU_A

    mux_2to1 #(.WIDTH(32)) mux_ALU_A(.sel(ALUSrcA_ex),.in0(ALU_A_temp),.in1(RsData_ex),.out(ALU_A));

//MUX for ALU_B

    mux_2to1 #(.WIDTH(32)) mux_ALU_B(.sel(ALUSrcB_ex),.in0(ALU_B_temp),.in1(RtData_ex),.out(ALU_B));

//ALU inst
	 ALU  ALU (
	 // Outputs
	.Result(ALUResult_ex),
	.overflow(),
	// Inputs
	.ALUCode(ALUCode_ex), 
	.A(ALU_A), 
	.B(ALU_B)
);
	 
//MUX for RegWriteAddr_ex

    mux_2to1 #(.WIDTH(5)) mux_RegDst(.sel(RegDst_ex),.in0(RtAddr_ex),in1(RdAddr_ex),.out(RegWriteAddr_ex));


endmodule
