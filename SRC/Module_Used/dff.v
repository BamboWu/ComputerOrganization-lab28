module dff(clk,r,d,q);
    parameter WIDTH=1;
	input wire clk,r;
	input wire[WIDTH-1:0] d;
	output reg[WIDTH-1:0] q;
	
	always @(posedge clk or posedge r)
	    begin
		    case(r)
			1'b1 : q<=0;
			1'b0 : q<=d[WIDTH-1:0];
			endcase
		end
endmodule