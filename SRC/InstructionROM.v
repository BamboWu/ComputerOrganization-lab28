
module InstructionROM(addr,dout);
	input [5 : 0] addr;
	output [31 : 0] dout;
	//
	reg [31 : 0] dout;
	always @(*)
		case (addr) /* addr = PC/4 */
			6'd0:   dout=32'h0800000b ; /* op=2h offset=0bh                                        */   
			                            /* j 0bh # jump to 6'd11, PC = 2ch                         */   
			6'd1:   dout=32'h20080042 ; /* op=8h rs=0 rt=8 imm=42h                                 */   
                                        /* addi $t0, $zero, 66           			               */   
			6'd2:   dout=32'h20090004 ; /* op=8h rs=0 rt=9 imm=4h                                  */   
			                            /* addi $t1, $zero, 4                                      */   
			6'd3:   dout=32'h01095022 ; /* op=0h rs=8 rt=9 rd=10 sa=0h func=22h                    */   
			                            /* sub  $t2, $t0, $t1                                      */   
			6'd4:   dout=32'h01485825 ; /* op=0h rs=10 rt=8 rd=11 sa=0h func=25h                   */   
			                            /* or   $t3, $t2, $t0                                      */   
			6'd5:   dout=32'hac0b000c ; /* op=2bh rs=0 rt=11 offset=0ch                            */   
			                            /* sw   $t3, 12($zero)                                     */   
			6'd6:   dout=32'h8d2c0008 ; /* op=23h rs=9 rt=12 offset=0bh                            */   
			                            /* lw   $t4, 11($t1)                                       */   
			6'd7:   dout=32'h000c4080 ; /* op=0h rs=0 rt=12 rd=8 sa=2h func=0h                     */   
			                            /* sll  $t0, $t4, 2                                        */   
			6'd8:   dout=32'h8d2b0008 ; /* op=23h rs=9 rt=11 offset=0bh                            */   
			                            /* lw   $t3, 11($t1)                                       */   
			6'd9:   dout=32'h012a582b ; /* op=0h rs=9 rt=10 rd=11 sa=0h func=2bh                   */   
			                            /* sltu $t3, $t1, $t2                                      */   
			6'd10:  dout=32'h0800000a ; /* op=2h offset=0ah                                        */   
			                            /* j 0ah # jump to itself                                  */   
			6'd11:  dout=32'h14000001 ; /* op=5h rs=0 rt=0 offset=1                                */   
			                            /* bne $zero, $zero, 1   # step to next instruction anyway */   
			6'd12:  dout=32'h1000fff4 ; /* op=4h rs=0 rt=0 offset=-0ch                             */   
			                            /* beq $zero, $zero, -11 # back to 6b'1                    */   
			6'd13:  dout=32'h00000000 ; /* nop                                                     */   
			default:dout=32'h00000000 ; /* nop                                                     */   
		endcase	
endmodule

