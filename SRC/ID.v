`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ZJU
// Engineer: 
// 
// Create Date:    16:02:45 11/12/2009 
// Design Name: 
// Module Name:    ID 
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
module ID(clk,Instruction_id, NextPC_id, RegWrite_wb, RegWriteAddr_wb, RegWriteData_wb, MemRead_ex, 
          RegWriteAddr_ex, MemtoReg_id, RegWrite_id, MemWrite_id, MemRead_id, ALUCode_id, 
    	  ALUSrcA_id, ALUSrcB_id, RegDst_id, Stall, Z, J, JR, PC_IFWrite,  BranchAddr, JumpAddr, JrAddr,
		  Imm_id, Sa_id, RsData_id, RtData_id, RsAddr_id, RtAddr_id, RdAddr_id);
    input clk;
	input [31:0] Instruction_id;
    input [31:0] NextPC_id;
    input RegWrite_wb;
    input [4:0] RegWriteAddr_wb;
    input [31:0] RegWriteData_wb;
    input MemRead_ex;
    input [4:0] RegWriteAddr_ex;
    output MemtoReg_id;
    output RegWrite_id;
    output MemWrite_id;
    output MemRead_id;
    output [4:0] ALUCode_id;
    output ALUSrcA_id;
    output ALUSrcB_id;
    output RegDst_id;
    output Stall;
    output reg Z;
    output J;
    output JR;
    output PC_IFWrite;
    output [31:0] BranchAddr;
    output [31:0] JumpAddr;
    output [31:0] JrAddr;
    output [31:0] Imm_id;
    output [31:0] Sa_id;
    output [31:0] RsData_id;
    output [31:0] RtData_id;
    output [4:0] RsAddr_id;
    output [4:0] RtAddr_id;
    output [4:0] RdAddr_id;



//	 
	 assign RtAddr_id=Instruction_id[20:16];
	 assign RdAddr_id=Instruction_id[15:11];
	 assign RsAddr_id=Instruction_id[25:21];

	 assign Sa_id  = {27'b0,Instruction_id[10:6]};
   	 assign Imm_id={{16{Instruction_id[15]}},Instruction_id[15:0]};   /* sign-extend */
	 
//JumpAddress

     assign JumpAddr = {NextPC_id[31:28],Instruction_id[25:0],2'b00};
   
//BranchAddrress 

     adder_32bits adder_Branch(.a(NextPC_id),.b({Imm_id[29:0],2'b00}),.ci(1'b0),.s(BranchAddr),.co());

//JrAddress

     assign JrAddr = RsData_id;

//Zero test
   parameter	 alu_beq=  5'b01010;
   parameter	 alu_bne=  5'b01011;
   parameter	 alu_bgez= 5'b01100;
   parameter	 alu_bgtz= 5'b01101;
   parameter	 alu_blez= 5'b01110;
   parameter	 alu_bltz= 5'b01111;

    always@(*)
     case(ALUCode_id)
	    alu_beq: Z = &(RsData_id[31:0]~^RtData_id[31:0]);
		alu_bne: Z = |(RsData_id[31:0]^RtData_id[31:0]);
		alu_bgez:Z = ~RsData_id[31];
		alu_bgtz:Z = ~RsData_id[31] &&(|RsData_id[30:0]);
		alu_bltz:Z = RsData_id[31];
		alu_blez:Z = RsData_id[31] ||~(&RsData_id[30:0]);
		default: Z = 31{1'b0};
	 endcase
	 
//Hazard detectior   

    assign stall =	MemRead_ex && 
	                ( (RsAddr_id==RegWriteAddr_ex)||
					  (RtAddr_id==RegWriteAddr_ex)  );
	assign PC_IFWrite = ~stall;		

//	Decode inst
   Decode  Decode(   
		// Outputs
		.MemtoReg(MemtoReg_id), 
		.RegWrite(RegWrite_id), 
		.MemWrite(MemWrite_id), 
		.MemRead(MemRead_id),
		.ALUCode(ALUCode_id),
		.ALUSrcA(ALUSrcA_id),
		.ALUSrcB(ALUSrcB_id),
		.RegDst(RegDst_id),
		.J(J) ,
		.JR(JR), 
		// Inputs
	  .Instruction(Instruction_id)
    );
   	 
// Registers inst

   //MultiRegisters inst
   wire [31:0] RsData_temp,RtData_temp;
	
	MultiRegisters   MultiRegisters(
	// Outputs
	.RsData(RsData_temp), 
	.RtData(RtData_temp), 
	// Inputs
	.clk(clk),
	.WriteData(RegWriteData_wb), 
	.WriteAddr(RegWriteAddr_wb), 
	.RegWrite(RegWrite_wb),
	.RsAddr(RsAddr_id), 
	.RtAddr(RtAddr_id)
    );

	 
	//RsSel & RtSel
	
	wire RsSel,RtSel;
	
    assign {RsSel,RtSel} = {2{RegWrite_wb}} & {2{RegWriteAddr_wb~=6'd0}} &
	                         {(RsAddr_id==RegWriteAddr_wb),(RtAddr_id==RegWriteAddr_wb)};

   //MUX for RsData_id  &  MUX for RtData_id
	
	mux_2to1 #(.WIDTH(32)) mux_RsData_id(.sel(RsSel),.in0(RsData_temp),.in1(RegWriteData_wb),.out(RsData_id));
	mux_2to1 #(.WIDTH(32)) mux_RtData_id(.sel(RtSel),.in0(RtData_temp),.in1(RegWriteData_wb),.out(RtData_id));
	   

endmodule
