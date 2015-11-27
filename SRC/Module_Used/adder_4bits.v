module adder_4bits(a,b,ci,s,co);
    input [3:0] a,b;
	input ci;
	output reg[3:0] s;
	output reg co;
	wire[3:0] P,G,C;
	
	assign P=a|b;
	assign G=a&b;
	assign C={  G[3] | P[3]&G[2] | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0] | P[3]&P[2]&P[1]&P[0]&ci,
	            G[2] | P[2]&G[1] | P[2]&P[1]&G[0] | P[2]&P[1]&P[0]&ci,
			    G[1] | P[1]&G[0] | P[1]&P[0]&ci,
			    G[0] | P[0]&ci
	};
	always@(*)
	    begin
		    s=P & ~G ^ {C[2:0],ci};
			co=G[3] | P[3]&C[3];
		end
endmodule