`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ZJU
// Engineer: 
// 
// Create Date:    19:44:48 11/12/2009 
// Design Name: 
// Module Name:    MipsPipelineCPU 
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
module MipsPipelineCPU(clk, reset, JumpFlag, Instruction_id, ALU_A, 
                     ALU_B, ALUResult, PC, MemDout_wb,Stall
						//	,DataTest,ControlTest
							);
    input clk;
    input reset;
    output[2:0] JumpFlag;
    output [31:0] Instruction_id;
    output [31:0] ALU_A;
    output [31:0] ALU_B;
    output [31:0] ALUResult;
    output [31:0] PC;
    output [31:0] MemDout_wb;
    output Stall;
//  output[31:0] DataTest;
//  output    ControlTest;
	 
//IF  module
     wire[31:0] Instruction_id;
	 wire PC_IFWrite,J,JR,Z,IF_flush;
	 wire[31:0] JumpAddr,JrAddr,BranchAddr,NextPC_if,Instruction_if;
	 assign JumpFlag={JR,J,Z};
	 assign IF_flush=Z || J ||JR;
	
	IF IF(
//input	
	 .clk(clk), 
	 .reset(reset), 
	 .Z(Z), 
	 .J(J), 
	 .JR(JR), 
	 .PC_IFWrite(PC_IFWrite), 
	 .JumpAddr(JumpAddr), 
	 .JrAddr(JrAddr), 
	 .BranchAddr(BranchAddr), 
//  output
	 .Instruction_if(Instruction_if),
	 .PC(PC),
	 .NextPC_if(NextPC_if));
 
//   IF->ID Register

     wire[31:0] NextPC_id;
     dffr #(.WIDTH(64)) IFdffID(.clk(clk&PC_IFWrite),.r(reset|IF_flush),
	                            .d({NextPC_if,Instruction_if}),
						        .q({NextPC_id,Instruction_id}));

     
//  ID Module	
    wire[4:0] RtAddr_id,RdAddr_id,RsAddr_id;
    wire  RegWrite_wb,MemRead_ex,MemtoReg_id,RegWrite_id,MemWrite_id;
    wire  MemRead_id,ALUSrcA_id,ALUSrcB_id,RegDst_id,stall;
    wire[4:0]  RegWriteAddr_wb,RegWriteAddr_ex,ALUCode_id;
    wire[31:0] RegWriteData_wb,Imm_id,Sa_id,RsData_id,RtData_id;
    ID  ID (
	    .clk(clk),
		.Instruction_id(Instruction_id), 
		.NextPC_id(NextPC_id), 
		.RegWrite_wb(RegWrite_wb), 
		.RegWriteAddr_wb(RegWriteAddr_wb), 
		.RegWriteData_wb(RegWriteData_wb), 
		.MemRead_ex(MemRead_ex), 
        .RegWriteAddr_ex(RegWriteAddr_ex), 
		.MemtoReg_id(MemtoReg_id), 
		.RegWrite_id(RegWrite_id), 
		.MemWrite_id(MemWrite_id), 
		.MemRead_id(MemRead_id), 
		.ALUCode_id(ALUCode_id), 
		.ALUSrcA_id(ALUSrcA_id), 
		.ALUSrcB_id(ALUSrcB_id), 
		.RegDst_id(RegDst_id), 
		.Stall(Stall), 
		.Z(Z), 
		.J(J), 
		.JR(JR), 
		.PC_IFWrite(PC_IFWrite),  
		.BranchAddr(BranchAddr), 
		.JumpAddr(JumpAddr),
		.JrAddr(JrAddr),
		.Imm_id(Imm_id), 
		.Sa_id(Sa_id), 
		.RsData_id(RsData_id), 
		.RtData_id(RtData_id),
		.RtAddr_id(RtAddr_id),
		.RdAddr_id(RdAddr_id),
		.RsAddr_id(RsAddr_id));

//   ID->EX  Register

	 wire[4:0] RdAddr_ex,RsAddr_ex,RtAddr_ex,ALUCode_ex;
     wire MemtoReg_ex,RegWrite_ex,MemWrite_ex;
	 wire[31:0] Sa_ex,Imm_ex,RsData_ex,RtData_ex;
	 dffr DFF(.clk(clk),.r(reset),.d(MemRead_id),.q(MemRead_ex));
     dffr #(.WIDTH(155)) IDdffEX(.clk(clk),.r(reset|Stall),
    	                         .d({MemtoReg_id,RegWrite_id, MemWrite_id,/*MemRead_id, /*1+1+1+1*/
    							     ALUCode_id,ALUSrcA_id,ALUSrcB_id,RegDst_id, /*5+1+1+1*/ /*32+32+5+5+5+32+32*/
    							     Sa_id,Imm_id,RdAddr_id,RsAddr_id,RtAddr_id,RsData_id,RtData_id}),
    						     .q({MemtoReg_ex,RegWrite_ex,MemWrite_ex,/*MemRead_ex,*/
    							     ALUCode_ex,ALUSrcA_ex,ALUSrcB_ex,RegDst_ex,
    							     Sa_ex,Imm_ex,RdAddr_ex,RsAddr_ex,RtAddr_ex,RsData_ex,RtData_ex}));



// EX Module	 
 wire[31:0] ALUResult_mem,ALUResult_ex,MemWriteData_ex;
 wire[4:0] RegWriteAddr_mem;
 wire RegWrite_mem;
 EX  EX(
 .RegDst_ex(RegDst_ex), 
 .ALUCode_ex(ALUCode_ex), 
 .ALUSrcA_ex(ALUSrcA_ex), 
 .ALUSrcB_ex(ALUSrcB_ex), 
 .Imm_ex(Imm_ex), 
 .Sa_ex(Sa_ex), 
 .RsAddr_ex(RsAddr_ex), 
 .RtAddr_ex(RtAddr_ex), 
 .RdAddr_ex(RdAddr_ex),
 .RsData_ex(RsData_ex), 
 .RtData_ex(RtData_ex), 
 .RegWriteData_wb(RegWriteData_wb), 
 .ALUResult_mem(ALUResult_mem), 
 .RegWriteAddr_wb(RegWriteAddr_wb), 
 .RegWriteAddr_mem(RegWriteAddr_mem), 
 .RegWrite_wb(RegWrite_wb), 
 .RegWrite_mem(RegWrite_mem), 
 .RegWriteAddr_ex(RegWriteAddr_ex), 
 .ALUResult_ex(ALUResult_ex), 
 .MemWriteData_ex(MemWriteData_ex), 
 .ALU_A(ALU_A), 
 .ALU_B(ALU_B));

assign ALUResult=ALUResult_ex;

//EX->MEM
     wire[31:0] MemWriteData_mem;
     wire MemtoReg_mem;
     dffr #(.WIDTH(72)) EXdffMEM(.clk(clk),.r(reset),
	                             .d({MemtoReg_ex,RegWrite_ex,MemWrite_ex, /*1+1+1+1*/
			 					    ALUResult_ex,MemWriteData_ex,RegWriteAddr_ex}), /*32+32+5*/
			    				 .q({MemtoReg_mem,RegWrite_mem,MemWrite_mem,
			 					    ALUResult_mem,MemWriteData_mem,RegWriteAddr_mem}));


//MEM Module
	DataRAM   DataRAM(
	.addr(ALUResult_mem[7:2]),
	.clk(clk),
	.din(MemWriteData_mem),
	.dout(MemDout_wb),
	.we(MemWrite_mem));

//MEM->WB
  
    dffr #(.WIDTH(39)) MEMdffWB(.clk(clk),.r(reset),
	                            .d({MemtoReg_mem,RegWrite_mem,       /*1+1*/
							        ALUResult_mem,RegWriteAddr_mem}),/*32+5*/
							    .q({MemToReg_wb,RegWrite_wb,
							        ALUResult_wb,RegWriteAddr_wb}));

//WB
  assign RegWriteData_wb=MemToReg_wb?MemDout_wb:ALUResult_wb;


endmodule
