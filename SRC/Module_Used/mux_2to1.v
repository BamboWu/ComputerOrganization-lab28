module mux_2to1(sel,in0,in1,out);
    parameter WIDTH=1;
	input sel;
	input[WIDTH-1:0] in0,in1;
	output reg[WIDTH-1:0] out;
	
	always@(*)
		case(sel)
	        1'b0: out=in0;
		    1'b1: out=in1;
	    endcase
endmodule