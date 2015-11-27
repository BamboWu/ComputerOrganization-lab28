module adder_8bits(a,b,ci,s,co);
    input[7:0] a,b;
	input ci;
	output reg[7:0] s;
	output reg co;
	
	wire[3:0] s_3_0,s_7_4,s_7_4_0,s_7_4_1;
	wire co_0,co_1,co_1_0,co_1_1;
	adder_4bits adder_3_0(.a(a[3:0]),.b(b[3:0]),.ci(ci),.s(s_3_0),.co(co_0));
	adder_4bits adder_7_4_0(.a(a[7:4]),.b(b[7:4]),.ci(1'b0),.s(s_7_4_0),.co(co_1_0));
	adder_4bits adder_7_4_1(.a(a[7:4]),.b(b[7:4]),.ci(1'b1),.s(s_7_4_1),.co(co_1_1));
	
	mux_2to1 #(.WIDTH(5)) mux0(.sel(co_0),.in0({s_7_4_0,co_1_0}),.in1({s_7_4_1,co_1_1}),.out({s_7_4,co_1}));
	
	always@(*)
	    begin
		    s={s_7_4,s_3_0};
			co=co_1;
		end
endmodule