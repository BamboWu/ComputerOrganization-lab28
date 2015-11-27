module pipeline_adder(clk,a,b,ci,s,co);
    input clk,ci;
	input[31:0] a,b;
	output reg[31:0] s;
	output reg co;
	
	wire add1_ci,add1_co,add2_ci,add2_co,add3_ci,add3_co,add4_ci,add4_co;
	wire[7:0] add1_a,add1_b,add1_s,add2_a,add2_b,add2_s,add3_a,add3_b,add3_s,add4_a,add4_b,add4_s;
	wire[31:8] add1_a_,add1_b_;
	wire[31:16] add2_a_,add2_b_;
	wire[31:24] add3_a_,add3_b_;
	wire[7:0] s_7_0_1,s_7_0_2,s_7_0_3,s_7_0_4,s_15_8_2,s_15_8_3,s_15_8_4,s_23_16_3,s_23_16_4,s_31_24_4;
	wire co_4;
	
	dff #(.WIDTH(65)) cache0(.clk(clk),.r(1'b0),.d({ci,a,b}),.q({add1_ci,add1_a_,add1_a,add1_b_,add1_b}));
	adder_8bits add1(.a(add1_a),.b(add1_b),.ci(add1_ci),.s(add1_s),.co(add1_co));
	dff #(.WIDTH(65)) cache1(.clk(clk),.r(1'b0),.d({add1_s,add1_co,add1_a_,add1_b_}),.q({s_7_0_1,add2_ci,add2_a_,add2_a,add2_b_,add2_b}));
	adder_8bits add2(.a(add2_a),.b(add2_b),.ci(add2_ci),.s(add2_s),.co(add2_co));
	dff #(.WIDTH(65)) cache2(.clk(clk),.r(1'b0),.d({s_7_0_1,add2_s,add2_co,add2_a_,add2_b_}),.q({s_7_0_2,s_15_8_2,add3_ci,add3_a_,add3_a,add3_b_,add3_b}));
	adder_8bits add3(.a(add3_a),.b(add3_b),.ci(add3_ci),.s(add3_s),.co(add3_co));
	dff #(.WIDTH(65)) cache3(.clk(clk),.r(1'b0),.d({s_7_0_2,s_15_8_2,add3_s,add3_co,add3_a_,add3_b_}),.q({s_7_0_3,s_15_8_3,s_23_16_3,add4_ci,add4_a,add4_b}));
	adder_8bits add4(.a(add4_a),.b(add4_b),.ci(add4_ci),.s(add4_s),.co(add4_co));
	dff #(.WIDTH(65)) cache4(.clk(clk),.r(1'b0),.d({s_7_0_3,s_15_8_3,s_23_16_3,add4_s,add4_co}),.q({s_7_0_4,s_15_8_4,s_23_16_4,s_31_24_4,co_4}));

	always@(*)
	    begin
		    s={s_31_24_4,s_23_16_4,s_15_8_4,s_7_0_4};
			co=co_4;
		end
endmodule