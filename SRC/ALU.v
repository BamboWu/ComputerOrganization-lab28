//******************************************************************************
// MIPS verilog model
//
// ALU.v
//
// The ALU performs all the arithmetic/logical integer operations 
// specified by the ALUsel from the decoder. 
// 
// verilog written QMJ
// modified by 
// modified by 
//
//******************************************************************************

module ALU (
	// Outputs
	Result,overflow,
	// Inputs
	ALUCode, A, B
);

	input [4:0]	ALUCode;				// Operation select
	input [31:0]	A, B;

	output reg[31:0]	Result;
	output overflow;

//******************************************************************************
// Shift operation: ">>>" will perform an arithmetic shift, but the operand
// must be reg signed
//******************************************************************************
	reg signed [31:0] B_reg;
	
	always @(B) begin
		B_reg = B;
	end

	
// Decoded ALU operation select (ALUsel) signals
   parameter	 alu_add=  5'b00000;
   parameter	 alu_and=  5'b00001;
   parameter	 alu_xor=  5'b00010;
   parameter	 alu_or =  5'b00011;
   parameter	 alu_nor=  5'b00100;
   parameter	 alu_sub=  5'b00101;
   parameter	 alu_andi= 5'b00110;
   parameter	 alu_xori= 5'b00111;
   parameter	 alu_ori = 5'b01000;
   parameter     alu_jr =  5'b01001;
   parameter	 alu_beq=  5'b01010;
   parameter	 alu_bne=  5'b01011;
   parameter	 alu_bgez= 5'b01100;
   parameter	 alu_bgtz= 5'b01101;
   parameter	 alu_blez= 5'b01110;
   parameter	 alu_bltz= 5'b01111;
   parameter 	 alu_sll=  5'b10000;
   parameter	 alu_srl=  5'b10001;
   parameter	 alu_sra=  5'b10010;	
   parameter	 alu_slt=  5'b10011;
   parameter	 alu_sltu= 5'b10100;
   
  
  
   
   

	
//******************************************************************************
// ALU Result datapath
//******************************************************************************

   wire[31:0] Res_and,Res_xor,Res_or,Res_nor,Res_andi,Res_xori,Res_ori;
   wire[31:0] Res_sll,Res_srl,Res_sra,Res_slt,Res_sltu;
   wire[31:0] sum;
   wire Binvert;
   
   assign Binvert = ~(ALUCode==alu_add || ALUCode==alu_sltu);
   
   adder_32bits adder_ALU(.a(A),.b(B^{32{Binvert}}),.ci(Binvert),.s(sum),.co(overflow));
   /*assign Res_add = A + B;*/
   /*assign Res_and = A & B;
   assign Res_xor = A ^ B;
   assign Res_or  = A | B;
   assign Res_nor = ~(A | B);*/
   /*assign Res_sub = A - B;*/
   /*assign Res_andi= A & {16'd0,B[15:0]};
   assign Res_xori= A ^ {16'd0,B[15:0]};
   assign Res_ori = A | {16'd0,B[15:0]};

   assign Res_sll = B << A;
   assign Res_srl = B >> A;
   assign Res_sra = B_reg >>> A;
   
   assign Res_slt = A[31]&&(~B[31]) || (A[31]~^B[31])&&sum[31];
   assign Res_sltu= &{overflow,sum};*/
   
   always@(*)
    case(ALUCode)
	  alu_add  : Result = sum[31:0];
	  alu_sub  : Result = sum[31:0];
      alu_and  : Result = A & B;	  
      alu_xor  : Result = A ^ B;	  
      alu_or   : Result = A | B;	  
      alu_nor  : Result = ~(A | B);	  
      alu_andi : Result = A & {16'd0,B[15:0]};
      alu_xori : Result = A ^ {16'd0,B[15:0]};
      alu_ori  : Result = A | {16'd0,B[15:0]};
      alu_sll  : Result = B << A;
      alu_srl  : Result = B >> A;
      alu_sra  : Result = B_reg >>> A;
      alu_slt  : Result = A[31]&&(~B[31]) || (A[31]~^B[31])&&sum[31];
      alu_sltu : Result = &{overflow,sum};
      default  : Result = {32{1'bz}};
    endcase	  
	  
endmodule