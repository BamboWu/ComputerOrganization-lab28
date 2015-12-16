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
    input  clk;
    input  reset;
    output [2:0]  JumpFlag;
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
    wire[31:0] NextPC_if,Instruction_if;
	/* Feedbacks from ID */
	wire PC_IFWrite,J,JR,Z;
	wire[31:0] JumpAddr,JrAddr,BranchAddr;
	 
	IF IF(
//input	
	.clk(clk), 
	.reset(reset), 
	.PC_IFWrite(PC_IFWrite), 
	.J(J), 
	.JR(JR), 
	.Z(Z), 
	.JumpAddr(JumpAddr), 
	.JrAddr(JrAddr), 
	.BranchAddr(BranchAddr), 
//output
	.PC(PC),  /* a probe, defined at very begining */
	.NextPC_if(NextPC_if),
	.Instruction_if(Instruction_if));
	 
	/* a probe, defined at the very beginning */
	assign JumpFlag={JR,J,Z};
 
//IF->ID Register
    wire[31:0] NextPC_id,Instruction_id;
    /* Combined feedbacks from ID */
    wire IF_flush;
	assign IF_flush=Z || J ||JR;
    
    dffre #(.WIDTH(64)) IF2ID(.clk(clk),.en(PC_IFWrite),.r(reset|IF_flush),
	       /*32+32*/         .d({NextPC_if,Instruction_if}),
						     .q({NextPC_id,Instruction_id}));
     
//ID Module	
    wire  MemToReg_id,RegWrite_id,MemWrite_id,MemRead_id,ALUSrcA_id,ALUSrcB_id,RegDst_id;
    wire[31:0] Imm_id,Sa_id,RsData_id,RtData_id;
    wire[4:0] ALUCode_id,RtAddr_id,RdAddr_id,RsAddr_id;
    /* Feedbacks from MEM2WB*/
    wire  RegWrite_wb;
    wire[4:0]  RegWriteAddr_wb;
    wire[31:0] RegWriteData_wb;
	/* Feedback from ID2EX */
    wire  MemRead_ex;
    /* Feedbacks from EX*/
    wire[4:0]  RegWriteAddr_ex;
	/* Feedbacks from MEM */
	wire[31:0] ALUResult_mem;
	wire[4:0] RegWriteAddr_mem;
	wire RegWrite_mem;
	/* Feedback from EX2MEM */
	wire MemRead_mem;
	
    ID ID(
	.clk(clk),
	.NextPC_id(NextPC_id), 
	.Instruction_id(Instruction_id), 
	.RegWrite_wb(RegWrite_wb), 
	.RegWrite_mem(RegWrite_mem), 
	.RegWriteAddr_wb(RegWriteAddr_wb), 
	.RegWriteData_wb(RegWriteData_wb), 
	.ALUResult_mem(ALUResult_mem),
	.MemRead_ex(MemRead_ex), 
	.MemRead_mem(MemRead_mem), 
    .RegWriteAddr_ex(RegWriteAddr_ex), 
    .RegWriteAddr_mem(RegWriteAddr_mem), 
    /*output*/
	.MemtoReg_id(MemToReg_id), 
	.RegWrite_id(RegWrite_id), 
	.MemWrite_id(MemWrite_id), 
	.MemRead_id(MemRead_id), 
	.ALUCode_id(ALUCode_id), 
	.ALUSrcA_id(ALUSrcA_id), 
	.ALUSrcB_id(ALUSrcB_id), 
	.RegDst_id(RegDst_id), 
	.Stall(Stall),/* also work as a probe, defined at the very beginning */
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

//ID->EX  Registers

    wire MemToReg_ex,RegWrite_ex;
    wire MemWrite_ex; /*MemRead_ex feedback to ID*/
	wire[4:0] ALUCode_ex;
	wire ALUSrcA_ex,ALUSrcB_ex,RegDst_ex;
	wire[31:0] Sa_ex,Imm_ex,RsData_ex,RtData_ex;
	wire[4:0] RdAddr_ex,RsAddr_ex,RtAddr_ex;
	 
	dffre #(.WIDTH(2))   ID2EX_wb(.clk(clk),.r(reset),.en(~Stall),
	       /*1+1*/      /* WB */ .d({MemToReg_id,RegWrite_id}),
	    				  		 .q({MemToReg_ex,RegWrite_ex}));
	dffre #(.WIDTH(2))   ID2EX_mem(.clk(clk),.r(reset),.en(~Stall),
	       /*1+1*/      /* M */   .d({MemWrite_id,MemRead_id}),
						  		  .q({MemWrite_ex,MemRead_ex}));
	dffre #(.WIDTH(8))   ID2EX_ex(.clk(clk),.r(reset),.en(~Stall),
	       /*5+1+1+1*/  /* EX */ .d({ALUCode_id,ALUSrcA_id,ALUSrcB_id,RegDst_id}),
								 .q({ALUCode_ex,ALUSrcA_ex,ALUSrcB_ex,RegDst_ex}));
	dffre #(.WIDTH(143)) ID2EX_Data(.clk(clk),.r(reset),.en(~Stall),
	       /*32*2+5*3+32*2*/       .d({Sa_id,Imm_id,RdAddr_id,RsAddr_id,RtAddr_id,RsData_id,RtData_id}),
								   .q({Sa_ex,Imm_ex,RdAddr_ex,RsAddr_ex,RtAddr_ex,RsData_ex,RtData_ex}));

// EX Module
    /*wire[4:0] RegWriteAddr_ex has feedback to ID */
    /*wire[31:0] ALUResult_mem; has feedback to ID */
    /*wire[4:0] RegWriteAddr_mem; has feedback to ID */
    /*wire RegWrite_mem; has feedback to ID */
    wire[31:0] ALUResult_ex,MemWriteData_ex;
    /* RegWriteAddr_wb,RegWriteData_wb feedback from WB defined at ID stage*/
 
    EX EX(
    .ALUCode_ex(ALUCode_ex), 
    .ALUSrcA_ex(ALUSrcA_ex), 
    .ALUSrcB_ex(ALUSrcB_ex), 
    .RegDst_ex(RegDst_ex), 
    .Sa_ex(Sa_ex), 
    .Imm_ex(Imm_ex), 
    .RdAddr_ex(RdAddr_ex),
    .RsAddr_ex(RsAddr_ex), 
    .RtAddr_ex(RtAddr_ex), 
    .RsData_ex(RsData_ex), 
    .RtData_ex(RtData_ex), 
    .RegWrite_wb(RegWrite_wb), 
    .RegWriteAddr_wb(RegWriteAddr_wb), 
    .RegWriteData_wb(RegWriteData_wb), 
    .RegWrite_mem(RegWrite_mem), 
    .RegWriteAddr_mem(RegWriteAddr_mem), 
    .ALUResult_mem(ALUResult_mem), 
    /*output*/
    .RegWriteAddr_ex(RegWriteAddr_ex), 
    .ALUResult_ex(ALUResult_ex), 
    .MemWriteData_ex(MemWriteData_ex), 
    .ALU_A(ALU_A), /* two probes, defined at very beginning */
    .ALU_B(ALU_B));

    assign ALUResult=ALUResult_ex;
    /* a probe, defined at the very beginning */

//EX->MEM

    wire MemToReg_mem; /* RegWrite_mem feedbacks to ID */
	wire MemWrite_mem; /* MemRead_mem feedbacks to ID */
    wire[31:0] MemWriteData_mem;
	/* ALUResult_mem,RegWriteAddr_mem feedback to ID */
	dffr #(.WIDTH(2))  EX2MEM_wb(.clk(clk),.r(reset),
	       /*1+1*/     /* WB */  .d({MemToReg_ex,RegWrite_ex}),
		                         .q({MemToReg_mem,RegWrite_mem}));
	dffr #(.WIDTH(2))  EX2MEM_mem(.clk(clk),.r(reset),
	       /*1+1*/     /* M */   .d({MemRead_ex,MemWrite_ex}),
		                         .q({MemRead_mem,MemWrite_mem}));
	dffr #(.WIDTH(69)) EX2MEM_Data(.clk(clk),.r(reset),
	       /*32+32+5*/ /* Data */  .d({ALUResult_ex,MemWriteData_ex,RegWriteAddr_ex}),
								   .q({ALUResult_mem,MemWriteData_mem,RegWriteAddr_mem}));

//MEM Module
	DataRAM DataRAM(
	.addr(ALUResult_mem[7:2]),
	.clk(clk),
	.din(MemWriteData_mem),
	.dout(MemDout_wb),
	.we(MemWrite_mem));

//MEM->WB
    wire MemToReg_wb; /* RegWrite_wb feedbacks to ID */
	wire[31:0] ALUResult_wb; /* RegWriteAddr_wb feedbacks to ID */
    dffr #(.WIDTH(2))  MEM2WB_wb(.clk(clk),.r(reset),
	       /*1+1*/     /* WB */  .d({MemToReg_mem,RegWrite_mem}),
					     	     .q({MemToReg_wb,RegWrite_wb}));
	dffr #(.WIDTH(37)) MEM2WB_Data(.clk(clk),.r(reset),
		   /*32+5*/   /* Data */   .d({ALUResult_mem,RegWriteAddr_mem}),
							       .q({ALUResult_wb,RegWriteAddr_wb}));

//WB
  assign RegWriteData_wb=MemToReg_wb?MemDout_wb:ALUResult_wb;

endmodule
