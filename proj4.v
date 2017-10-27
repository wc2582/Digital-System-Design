//ECE319
//Grade	33.00 / 35.00
//Project4
//Weihe Chen
//Project description: Design a pipeline processor that will compute a third degree polynomial

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///the array multiplier
module array4x10(Mresult, a, b);
input [3:0]a;
input [9:0]b;
output [13:0]Mresult;
wire [2:0]s1, c1, s2, c2, s3, c3, s4, c4, s5, c5, s6, c6, s7, c7, s8, c8, s9, c9; 
wire [3:0]s10;
wire cout;

grouparray gp1(a[3:1]&{3{b[0]}},3'd0, a[2:0]&{3{b[1]}}, s1, c1);
grouparray gp2({a[3]&b[1],s1[2:1]},c1, a[2:0]&{3{b[2]}}, s2,c2);
grouparray gp3({a[3]&b[2],s2[2:1]},c2, a[2:0]&{3{b[3]}}, s3,c3);
grouparray gp4({a[3]&b[3],s3[2:1]},c3, a[2:0]&{3{b[4]}}, s4,c4);
grouparray gp5({a[3]&b[4],s4[2:1]},c4, a[2:0]&{3{b[5]}}, s5,c5);
grouparray gp6({a[3]&b[5],s5[2:1]},c5, a[2:0]&{3{b[6]}}, s6,c6);
grouparray gp7({a[3]&b[6],s6[2:1]},c6, a[2:0]&{3{b[7]}}, s7,c7);
grouparray gp8({a[3]&b[7],s7[2:1]},c7, a[2:0]&{3{b[8]}}, s8,c8);
//grouparray gp9({a[3]&b[8],s8[2:1]},c8, a[2:0]&{3{b[9]}}, s9,c9);
//grouparray gp10({a[3]&b[9],s9[2:1]},c9, a[2:0]&{3{b[10]}}, s10,c10);
grouparray2 gp11({a[3]&b[8],s8[2:1]},c8, a[2:0]&{3{b[9]}}, s9,c9);
grouparray3 gp12({a[3]&b[9],s9},{c9,1'b0},s10,cout);

assign Mresult={cout, s10, s8[0],s7[0],s6[0],s5[0],s4[0],s3[0],s2[0],s1[0],a[0]&b[0]};
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//the adder modules
//type0 adder
module adder0(x,y,z,s,c);
input x,y,z;
output s,c;

assign s=x^y^z;
assign c=(x&y)|((x^y)&z);
endmodule

//type1 adder
module adder1(x,y,z,s,c);
input x,y,z;
output s,c;

assign s=~(x^y^(~z));
assign c=(x&y)|((x^y)&~z);
endmodule

//type2 adder
module adder2(x,y,z,s,c);
input x,y,z;
output s,c;

assign s=(~x)^(~y)^z;
assign c=~(((~x)&(~y))|(((~x)^(~y))&z));
endmodule

//type3 adder
module adder3(x,y,z,s,c);
input x,y,z;
output s,c;

assign s=~((~x)^(~y)^(~z));
assign c=~(((~x)&(~y))|(((~x)^(~y))&(~z)));
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//group array module for first 10 rows in the array multiplier
module grouparray(x, y, z, s, c);
input [2:0]x,y,z;
output [2:0]s,c;
wire [2:0]x,y,z,s,c;

adder0 gpad00(x[0],y[0],z[0],s[0],c[0]);
adder0 gpad01(x[1],y[1],z[1],s[1],c[1]);
adder1 gpad12(x[2],y[2],z[2],s[2],c[2]);
endmodule

//group array module for 11th row in the array multiplier
module grouparray2(x, y, z, s, c);
input [2:0]x,y,z;
output [2:0]s,c;
wire [2:0]x,y,z,s,c;

adder1 gpad10(x[0],y[0],z[0],s[0],c[0]);
adder1 gpad11(x[1],y[1],z[1],s[1],c[1]);
adder3 gpad32(x[2],y[2],z[2],s[2],c[2]);
endmodule

//group array module for last row in the array multiplier
module grouparray3(x, y, s, cout);
input [3:0]x,y;
output [3:0]s;
output cout;
wire [3:0]x,y,z,s;
wire[2:0]c;
wire cout;

adder2 gpad20(x[0],1'b0,y[0],s[0],c[0]);
adder2 gpad21(x[1],c[0],y[1],s[1],c[1]);
adder2 gpad22(x[2],c[1],y[2],s[2],c[2]);
adder2 gpad23(y[3],c[2],x[3],s[3],cout);
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module PolyPipe(clock, reset, const3, const2, const1, const0, x, y);
input clock, reset;
input [3:0] const0, const1, const2, const3, x;
output [12:0] y;
reg [12:0]y;
reg [3:0] a0, a1, a2, a3, x11,x12,x13, x21,x22, x23;
wire [3:0]X1,X2;
/////////////////////////
reg [2:0]modcnt, moddelay;
reg [1:0]cyclecnt,cdelay;
reg [12:0]R,T,S1,S2;
wire [9:0]mult1in, mult2in;
wire [12:0]adderin1,adderin2;
wire [13:0]Mresult1, Mresult2;
wire [12:0]Aresult;
wire  m3, c_out, R_clt, T_clt, S1_clt1,S1_clt2, S2_clt1, S2_clt2, y_clt, x11_clt, x12_clt, x13_clt, x21_clt, x22_clt, x23_clt;
wire [1:0]m1, m2,m4, X1_clt,X2_clt;
always @(posedge reset)
begin
a0 <= const0;
a1 <= const1;
a2 <= const2;
a3 <= const3;
end
// rest of your code

//using multiplexers to choose inputs of multipliers and adder
mux4 #(4)  muxtomult1x(X1, {x11,x12,x13,4'd0},X1_clt);
mux4 #(4)  muxtomult2x(X2, {x21,x22,x23,4'd0},X2_clt);
mux4 #(10) muxtomult1(mult1in, { {{6{a3[3]}},a3}, S1[9:0], S2[9:0],10'd0},m1);
mux4 #(10) muxtomult2(mult2in, { {{6{a3[3]}},a3}, S1[9:0], S2[9:0],10'd0},m2);
mux2 #(13) muxtoadder1(adderin1, {R,T}, m3);
mux4 #(13) muxtoadder2(adderin2, { {{9{a2[3]}},a2},{{9{a1[3]}},a1},{{9{a0[3]}},a0}, 13'd0},m4);

//the array multipliers
array4x10 mult1(Mresult1,X1, mult1in);
array4x10 mult2(Mresult2,X2, mult2in);

//the CPA adder
cpa #(13) cpa(Aresult, c_out, adderin1, adderin2, 1'd0);

//set up the mod counter
always @(posedge reset or posedge clock)
begin
	if(reset)
		modcnt<=3'd7;
		else
		begin
		if(modcnt==3'd5)
			modcnt<=3'd0;
			else
				modcnt<=modcnt+3'd1;
				end
end

//half clcok dealy of the mod counter
always @(negedge clock)
       moddelay<=modcnt;

//cycle counter
always @(posedge reset or posedge clock&(moddelay==3'd5))
begin
	if(reset)
		cyclecnt<=2'd3;
		else
		begin
			if(cyclecnt==2'd2)
				cyclecnt<=2'd0;
					else
						cyclecnt<=cyclecnt+2'd1;
						end
end

//half delay of the cycle counter
always @(negedge clock or posedge reset)
       if(reset)
       cdelay<=3'd2;
       else
       cdelay<=cyclecnt;

//clocking of storing registers and their inputs
//R
always @(posedge clock&R_clt)
       R<=Mresult1[12:0];
//T
always @(posedge clock&T_clt)
       T<=Mresult2[12:0];
//S1
always @(posedge clock&S1_clt1)
       S1<=Aresult;
always @(posedge clock&S1_clt2)
       S1<=S2;
//S2
always @(posedge clock&S2_clt1)
       S2<=Aresult;
always @(posedge clock&S2_clt2)
       S2<=S1;
//y
always @(posedge clock&y_clt)
       y<=Aresult;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//x11
always @(posedge (clock&x11_clt)|reset)
       x11<=x;
//x12
always @(posedge clock&x12_clt)
       x12<=x;
//x13
always @(posedge clock&x13_clt)
       x13<=x;
//x21
always @(posedge clock&x21_clt)
       x21<=x;
//x22
always @(posedge clock&x22_clt)
       x22<=x;
//x23
always @(posedge clock&x23_clt)
       x23<=x;

//control for multiplexers
assign m1[1]=(modcnt==3'd0)|(modcnt==3'd1)|(modcnt==3'd2)|(modcnt==3'd4)|(modcnt==3'd5);
assign m1[0]=(modcnt==3'd0)|(modcnt==3'd1)|(modcnt==3'd3);
assign m2[1]=(modcnt==3'd0)|(modcnt==3'd3)|(modcnt==3'd4);
assign m2[0]=(modcnt==3'd1)|(modcnt==3'd2)|(modcnt==3'd3)|(modcnt==3'd4)|(modcnt==3'd5);
assign m3=(modcnt==3'd0)|(modcnt==3'd2)|(modcnt==3'd4);
assign m4[1]=(modcnt==3'd0)|(modcnt==3'd2)|(modcnt==3'd3)|(modcnt==3'd5);
assign m4[0]=(modcnt==3'd1)|(modcnt==3'd2)|(modcnt==3'd4)|(modcnt==3'd5);
//assign X1_clt=(((modcnt==3'd0)|(modcnt==3'd1)|(modcnt==3'd4)|(modcnt==3'd5))&(cyclecnt==2'd0))|(((modcnt==3'd2)|(modcnt==3'd3))&(cyclecnt==2'd1))|reset;
//assign X2_clt=(((modcnt==3'd3)|(modcnt==3'd4))&(cyclecnt==2'd0))|(((modcnt==3'd1)|(modcnt==3'd2)|(modcnt==3'd5))&(cyclecnt==2'd1))|((modcnt==3'd0)&(cyclecnt==2'd2));

assign X1_clt[1]=(((modcnt==3'd0)|(modcnt==3'd1)|(modcnt==3'd4)|(modcnt==3'd5))&(~(cyclecnt==2'd2)))|(((modcnt==3'd2)|(modcnt==3'd3))&(~(cyclecnt==2'd0)));
assign X1_clt[0]=(((modcnt==3'd0)|(modcnt==3'd1)|(modcnt==3'd4)|(modcnt==3'd5))&(~(cyclecnt==2'd1)))|(((modcnt==3'd2)|(modcnt==3'd3))&(~(cyclecnt==2'd2)));
assign X2_clt[1]=(((modcnt==3'd3)|(modcnt==3'd4))&(~(cyclecnt==2'd2)))|(((modcnt==3'd1)|(modcnt==3'd2)|(modcnt==3'd5))&(~(cyclecnt==2'd0)))|((modcnt==3'd0)&(~(cyclecnt==2'd1)));
assign X2_clt[0]=(((modcnt==3'd3)|(modcnt==3'd4))&(~(cyclecnt==2'd1)))|(((modcnt==3'd1)|(modcnt==3'd2)|(modcnt==3'd5))&(~(cyclecnt==2'd2)))|((modcnt==3'd0)&(~(cyclecnt==2'd0)));




//control for registers
assign R_clt=(moddelay==3'd1)|(moddelay==3'd3)|(moddelay==3'd5);
assign T_clt=(moddelay==3'd0)|(moddelay==3'd2)|(moddelay==3'd4);
assign S1_clt1=(moddelay==3'd0)|(moddelay==3'd2);
assign S1_clt2=(moddelay==3'd5);
assign S2_clt1=(moddelay==3'd3)|(moddelay==3'd5);
assign S2_clt2=(moddelay==3'd2);
assign y_clt=(moddelay==3'd1)|(moddelay==3'd4);
assign x11_clt=((moddelay==3'd5)&(cdelay==3'd2));
assign x12_clt=((moddelay==3'd5)&(cdelay==3'd0));
assign x13_clt=((moddelay==3'd5)&(cdelay==3'd1));
assign x21_clt=((moddelay==3'd2)&(cdelay==3'd0));
assign x22_clt=((moddelay==3'd2)&(cdelay==3'd1));
assign x23_clt=((moddelay==3'd2)&(cdelay==3'd2));
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module test_proj4;
wire [12:0]y;
wire clock,reset;
reg [7:0]xbyte;
wire [3:0]x;
reg [2:0]mod, mdelay;
wire x_clt;
reg eof;
integer data_file;
//initial states
initial
	begin
		data_file = $fopen("proj4.dat", "rb");
		end 

//mod counter
always @(posedge reset or posedge clock)
begin
	if(reset)
		mod<=3'd7;
		else
		begin
		if(mod==3'd5)
			mod<=3'd0;
			else
				mod<=mod+3'd1;
				end
end


//half clcok dealy of the mod counter
always @(negedge clock)
       mdelay<=mod;

always @(posedge (~clock&x_clt)|reset)
begin
	eof = $feof(data_file);
	if (eof == 0)
	$fscanf(data_file, "%d", xbyte);
	else
	begin
		$fclose(data_file);
			$finish;
			end
end



//control
assign x_clt=(mod==5)|(mod==2);
assign x=xbyte[3:0];

//wire [12:0]y1,y2,y3,y4,y5,y6;
//initialize clock and reset
init test_init(reset, clock);

//initialize the pipeline
PolyPipe mypipe(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, x, y);
/*PolyPipe mypipe1(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, 4'd14, y1);
PolyPipe mypipe2(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, 4'd13, y2);
PolyPipe mypipe3(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, 4'd12, y3);
PolyPipe mypipe4(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, 4'd11, y4);
PolyPipe mypipe5(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, 4'd10, y5);
PolyPipe mypipe6(clock, reset, 4'd2, 4'd13, 4'd11, 4'd0, 4'd9, y6);*/
endmodule