module adder_32bits(a,b,ci,s,co);
    input[31:0] a,b;
	input ci;
	output reg[31:0] s;
	output reg co;
	wire[3:0] s_3_0,
	          s_7_4,s_7_4_0,s_7_4_1,
			  s_11_8,s_11_8_0,s_11_8_1,
			  s_15_12,s_15_12_0,s_15_12_1,
			  s_19_16,s_19_16_0,s_19_16_1,
			  s_23_20,s_23_20_0,s_23_20_1,
			  s_27_24,s_27_24_0,s_27_24_1,
			  s_31_28,s_31_28_0,s_31_28_1;
	wire co_0,
	     co_1,co_1_0,co_1_1,
		 co_2,co_2_0,c0_2_1,
		 co_3,co_3_0,c0_3_1,
		 co_4,co_4_0,c0_4_1,
		 co_5,co_5_0,c0_5_1,
		 co_6,co_6_0,c0_6_1,
		 co_7,co_7_0,c0_7_1;
	
	adder_4bits adder_3_0(.a(a[3:0]),.b(b[3:0]),.ci(ci),.s(s_3_0),.co(co_0));
	adder_4bits adder_7_4_0(.a(a[7:4]),.b(b[7:4]),.ci(1'b0),.s(s_7_4_0),.co(co_1_0));
	adder_4bits adder_7_4_1(.a(a[7:4]),.b(b[7:4]),.ci(1'b1),.s(s_7_4_1),.co(co_1_1));
	adder_4bits adder_11_8_0(.a(a[11:8]),.b(b[11:8]),.ci(1'b0),.s(s_11_8_0),.co(co_2_0));
	adder_4bits adder_11_8_1(.a(a[11:8]),.b(b[11:8]),.ci(1'b1),.s(s_11_8_1),.co(co_2_1));
	adder_4bits adder_15_12_0(.a(a[15:12]),.b(b[15:12]),.ci(1'b0),.s(s_15_12_0),.co(co_3_0));
	adder_4bits adder_15_12_1(.a(a[15:12]),.b(b[15:12]),.ci(1'b1),.s(s_15_12_1),.co(co_3_1));
	adder_4bits adder_19_16_0(.a(a[19:16]),.b(b[19:16]),.ci(1'b0),.s(s_19_16_0),.co(co_4_0));
	adder_4bits adder_19_16_1(.a(a[19:16]),.b(b[19:16]),.ci(1'b1),.s(s_19_16_1),.co(co_4_1));
	adder_4bits adder_23_20_0(.a(a[23:20]),.b(b[23:20]),.ci(1'b0),.s(s_23_20_0),.co(co_5_0));
	adder_4bits adder_23_20_1(.a(a[23:20]),.b(b[23:20]),.ci(1'b1),.s(s_23_20_1),.co(co_5_1));
	adder_4bits adder_27_24_0(.a(a[27:24]),.b(b[27:24]),.ci(1'b0),.s(s_27_24_0),.co(co_6_0));
	adder_4bits adder_27_24_1(.a(a[27:24]),.b(b[27:24]),.ci(1'b1),.s(s_27_24_1),.co(co_6_1));
	adder_4bits adder_31_28_0(.a(a[31:28]),.b(b[31:28]),.ci(1'b0),.s(s_31_28_0),.co(co_7_0));
	adder_4bits adder_31_28_1(.a(a[31:28]),.b(b[31:28]),.ci(1'b1),.s(s_31_28_1),.co(co_7_1));

	mux_2to1 #(.WIDTH(5)) mux0(.sel(co_0),.in0({s_7_4_0,co_1_0}),.in1({s_7_4_1,co_1_1}),.out({s_7_4,co_1}));
	mux_2to1 #(.WIDTH(5)) mux1(.sel(co_1),.in0({s_11_8_0,co_2_0}),.in1({s_11_8_1,co_2_1}),.out({s_11_8,co_2}));
	mux_2to1 #(.WIDTH(5)) mux2(.sel(co_2),.in0({s_15_12_0,co_3_0}),.in1({s_15_12_1,co_3_1}),.out({s_15_12,co_3}));
	mux_2to1 #(.WIDTH(5)) mux3(.sel(co_3),.in0({s_19_16_0,co_4_0}),.in1({s_19_16_1,co_4_1}),.out({s_19_16,co_4}));
	mux_2to1 #(.WIDTH(5)) mux4(.sel(co_4),.in0({s_23_20_0,co_5_0}),.in1({s_23_20_1,co_5_1}),.out({s_23_20,co_5}));
	mux_2to1 #(.WIDTH(5)) mux5(.sel(co_5),.in0({s_27_24_0,co_6_0}),.in1({s_27_24_1,co_6_1}),.out({s_27_24,co_6}));
	mux_2to1 #(.WIDTH(5)) mux6(.sel(co_6),.in0({s_31_28_0,co_7_0}),.in1({s_31_28_1,co_7_1}),.out({s_31_28,co_7}));
	
	always@(*)
	    begin
		    s={s_31_28[3:0],s_27_24[3:0],s_23_20[3:0],s_19_16[3:0],s_15_12[3:0],s_11_8[3:0],s_7_4[3:0],s_3_0[3:0]};
			co=co_7;
		end
endmodule