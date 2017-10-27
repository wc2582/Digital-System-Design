//ECE319
//Grade	19.00 / 20.00
//Project1
//Project description: read in one 8-bit of data and outout 8-bit data, a set of 4 outputs are corresponding to a set of 4 inputs
//Weihe Chen
//wec217

//code for module
module prog1(clk, reset, in, out);
input clk,reset;
input [7:0]in;
output [7:0]out;

reg [7:0]out;  
reg [7:0]R0, R1, R2, R3;
reg [2:0]modcnt,cntnegedge;
wire addsub, m1, m2, m3, m4, c_out,r0_clt,r1_clt,r2_clt,r3_clt;
wire [7:0]sum, mux1out, mux2out, mux3out, mux4out;

//initialize and increment negedge counter
always@(negedge clk or reset)
begin
	if(reset) 		
	cntnegedge <= 3'd7;
	else
  	cntnegedge <= cntnegedge+3'd1;
end

//generatemod counter with  half clk delay of the negedge counter
always@(posedge clk or negedge reset)
begin
	modcnt <= cntnegedge;
	if(reset)
	R0<=in;	
end

//with positive edge clk triggered counter
	//controls of mux 
	assign m1 = ((modcnt==3'd3)||(modcnt==3'd7));	//1 for R1, 0 for R3
	assign m2 = ((modcnt==3'd3)||(modcnt==3'd4));	//1 for R0, 0 for R2
   	assign m3 = ((modcnt==3'd1)||(modcnt==3'd2));//1 for R2, 0 for R0
	assign m4 = ((modcnt==3'd1)||(modcnt==3'd2)||(modcnt==3'd5)||(modcnt==3'd6));	//1 for R2/R0, 0 for sum
	//control of add/sub	
	assign addsub = ((modcnt==3'd3)||(modcnt==3'd7));	//1 for sub, 0 for add

//with negative edge clk triggered counter	
	//controls of registers
	assign r0_clt = ((cntnegedge==3'd0)||(cntnegedge==3'd6))||reset;
	assign r1_clt = ((cntnegedge==3'd1)||(cntnegedge==3'd5));
	assign r2_clt = ((cntnegedge==3'd2)||(cntnegedge==3'd4));
	assign r3_clt = ((cntnegedge==3'd3)||(cntnegedge==3'd7));

//read input into registers
always@(posedge clk)
begin
	out <= mux4out;  //why one clock delay?
	if(r0_clt)	
	R0<=in;
	if(r1_clt)	
	R1<=in;
	if(r2_clt)	
	R2<=in;
	if(r3_clt)	
	R3<=in;
	
end

   //use mux modules
mux2 #(8) mux1(mux1out,{R1,R3},m1);
mux2 #(8) mux2(mux2out,{R0,R2},m2);
mux2 #(8) mux3(mux3out,{R2,R0},m3);
mux2 #(8) mux4(mux4out,{mux3out,sum},m4);

cpa #(8) cpa0(sum,c_out,mux1out,(mux2out^({8{addsub}})),addsub);

endmodule



//test bench
module test_proj1;
wire clk, reset;
reg [7:0]inr;
wire [7:0]outr;
reg eof;
integer data_file;

//generate reset and clk
init test_bench(reset, clk); 

   //initiallize readin register and data file name
initial
begin
	data_file = $fopen("proj1.dat", "rb");
      eof = $feof(data_file);
      if (eof == 0)
         $fscanf(data_file, "%d",inr);
      else
        begin
         $fclose(data_file);
         $finish;
        end
    end


//readfile for each clock
always @(posedge clk)
    begin
      eof = $feof(data_file);
      if (eof == 0)
         $fscanf(data_file, "%d",inr);
      else
        begin
         $fclose(data_file);
         $finish;
        end
    end


prog1 my_proj1(clk, reset, inr, outr);
endmodule













	

