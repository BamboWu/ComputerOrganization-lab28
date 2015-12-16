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
module ID(clk,Instruction_id, NextPC_id, RegWrite_wb, RegWrite_mem, RegWriteAddr_wb, RegWriteData_wb, ALUResult_mem, MemRead_ex, MemRead_mem, 
          RegWriteAddr_ex, RegWriteAddr_mem, MemtoReg_id, RegWrite_id, MemWrite_id, MemRead_id, ALUCode_id, 
    	  ALUSrcA_id, ALUSrcB_id, RegDst_id, Stall, Z, J, JR, PC_IFWrite,  BranchAddr, JumpAddr, JrAddr,
		  Imm_id, Sa_id, RsData_id, RtData_id, RsAddr_id, RtAddr_id, RdAddr_id);
    input clk;
	input [31:0] Instruction_id;
    input [31:0] NextPC_id;
    input RegWrite_wb;
    input RegWrite_mem;
    input [4:0] RegWriteAddr_wb;
    input [31:0] RegWriteData_wb;
    input [31:0] ALUResult_mem;
    input MemRead_ex;
    input MemRead_mem;
    input [4:0] RegWriteAddr_ex;
    input [4:0] RegWriteAddr_mem;
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
    output reg PC_IFWrite;
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
   
   
//forwarding
	wire[1:0] ForwardRs,ForwardRt;

	assign ForwardRs[0] = RegWrite_wb && (|RegWriteAddr_wb) &&  /* 2nd data hazard */
	                     ~(RegWriteAddr_mem==RsAddr_id) && (RegWriteAddr_wb==RsAddr_id);
	assign ForwardRs[1] = RegWrite_mem && (|RegWriteAddr_mem) &&
	                     (RegWriteAddr_mem==RsAddr_id);             /* 1st data hazard */

	assign ForwardRt[0] = RegWrite_wb && (|RegWriteAddr_wb) &&  /* 2nd data hazard */
	                     ~(RegWriteAddr_mem==RtAddr_id) && (RegWriteAddr_wb==RtAddr_id);
	assign ForwardRt[1] = RegWrite_mem && (|RegWriteAddr_mem) &&
	                     (RegWriteAddr_mem==RtAddr_id);             /* 1st data hazard */
//MUX for Rs
    
	wire[31:0] ALU_Rs_temp;
    mux_4to1 #(.WIDTH(32)) mux_Rs(.sel(ForwardRs),
	                             .in0(RsData_id),.in1(RegWriteData_wb),
								 .in2(ALUResult_mem),.in3(32'd0),.out(ALU_Rs_temp));

//MUX for Rt

	wire[31:0] ALU_Rt_temp;
    mux_4to1 #(.WIDTH(32)) mux_Rt(.sel(ForwardRt),
	                             .in0(RtData_id),.in1(RegWriteData_wb),
								 .in2(ALUResult_mem),.in3(32'd0),.out(ALU_Rt_temp));

    always@(*)
     case(ALUCode_id)
	    alu_beq: Z = &(ALU_Rs_temp[31:0]~^ALU_Rt_temp[31:0]);
		alu_bne: Z = |(ALU_Rs_temp[31:0]^ALU_Rt_temp[31:0]);
		alu_bgez:Z = ~ALU_Rs_temp[31];
		alu_bgtz:Z = ~ALU_Rs_temp[31] &&(|ALU_Rs_temp[30:0]);
		alu_bltz:Z = ALU_Rs_temp[31];
		alu_blez:Z = ALU_Rs_temp[31] ||~(&ALU_Rs_temp[30:0]);
		default: Z = {31{1'b0}};
	 endcase
	 
	wire Branch; /* Branch operation */
    assign Branch = (ALUCode_id==alu_beq)|(ALUCode_id==alu_bne)|(ALUCode_id==alu_bgez)|
	                (ALUCode_id==alu_bgtz)|(ALUCode_id==alu_bltz)|(ALUCode_id==alu_blez);	
	 
//Hazard detectior   

    //always@(*) Stall = MemRead_ex & ((RsAddr_id==RegWriteAddr_ex) | (RsAddr_id==RegWriteAddr_ex));
    assign Stall =	( MemRead_ex &
	                  (  (RsAddr_id==RegWriteAddr_ex)|
					     (RtAddr_id==RegWriteAddr_ex) ) |
					  MemRead_mem &
                      ( ((RsAddr_id==RegWriteAddr_mem)&Branch)|
					    ((RtAddr_id==RegWriteAddr_mem)&Branch) )
					);
	always@(negedge clk) PC_IFWrite = ~Stall;		

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
	
    assign {RsSel,RtSel} = {2{RegWrite_wb}} & {2{|RegWriteAddr_wb}} &
	                         {(RsAddr_id==RegWriteAddr_wb),(RtAddr_id==RegWriteAddr_wb)};

   //MUX for RsData_id  &  MUX for RtData_id
	
	mux_2to1 #(.WIDTH(32)) mux_RsData_id(.sel(RsSel),.in0(RsData_temp),.in1(RegWriteData_wb),.out(RsData_id));
	mux_2to1 #(.WIDTH(32)) mux_RtData_id(.sel(RtSel),.in0(RtData_temp),.in1(RegWriteData_wb),.out(RtData_id));
	   

endmodule
