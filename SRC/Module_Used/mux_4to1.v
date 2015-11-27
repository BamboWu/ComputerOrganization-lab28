module mux_4to1(sel,in0,in1,in2,in3,out);
    parameter WIDTH=1;
	input[1:0] sel;
	input[WIDTH-1:0] in0,in1,in2,in3;
	output reg[WIDTH-1:0] out;
	
	always@(*)
		case(sel)
	        2'b00: out=in0;
		    2'b01: out=in1;
		    3'b10: out=in2;
		    4'b11: out=in3;
	    endcase
endmodule