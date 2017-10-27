//ECE319
//Project 3
//Weihe Chen
//wec217
//Project description:  a First-In-First-Out (FIFO) buffer that can store up to 8 data words received at
//			port1 or port2 and deliver them in the same order at port3. 
//			The external systems that provide data at port1 and port2 use the sender originated
//			protocol and the system that requests data from port3 uses the receiver originated 
//			protocol. The system should reply to requet from any port as quickly as possible

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////proj3
module proj3(clock, reset, dready1, dready2, dreq3, ext1data, ext2data,dack1,dack2, dready3, port3_sender);
input clock, reset, dready1, dready2;
input[7:0]ext1data, ext2data;
output dack1, dack2, dready3, dreq3;
output [7:0]port3_sender;
wire dreq3;
reg [2:0]rdptr, wrptr;
wire incWRptr1, incWRptr2, setFull1, setFull2, resetEmpty1, resetEmpty2;
reg fullFF, emptyFF;
wire setFull, resetFull, setEmpty, resetEmpty, tgrant1, tgrant2, treq1, treq2;
//reg [2:0]arbstate, stateM1, stateM2, stateM3;
wire dack1, dack2, rd1, rd2, incWRptr, incRDptr, wr,x;
//reg [7:0]data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7];
reg [7:0]data[0:7];
wire [7:0] wrctrl,rdctrl;
reg[7:0]port3_sender;
//reg [7:0]port3_sender;

//the arbitor
arbitor my_arb(reset, clock, treq1, treq2, tgrant1, tgrant2);

//stateMachine1
stateMachineSender stateMachine1(reset,clock, x, tgrant1, dready1,fullFF, emptyFF, dack1, rd1, incWRptr1, setFull1, resetEmpty1, treq1);
//stateMachine2
stateMachineSender stateMachine2(reset,clock, x, tgrant2, dready2,fullFF, emptyFF, dack2, rd2, incWRptr2, setFull2, resetEmpty2, treq2);
//overall results generated 
assign incWRptr=incWRptr1|incWRptr2;
assign setFull=setFull1|setFull2;
assign resetEmpty=resetEmpty1|resetEmpty2;
//assign =dack1&dack2;
/*//rd is control for reading to one of the 16 registers
	assign rd=rd1|rd2;
*/
//stateMachine3 (wr is control for writing to output register)
stateMachineRecevier stateMachine3(reset,clock,x, dreq3,fullFF, emptyFF, dready3, wr, incRDptr, setEmpty, resetFull);

//other results
assign x=(rdptr==wrptr);

//fullFF
always @(posedge ~clock or posedge reset)
begin
	if(reset)
	fullFF<=1'd0;
	else
	begin
		if(setFull|resetFull)
		fullFF<=~fullFF;
	end
end
//emptyFF
always @(posedge ~clock or posedge reset)
begin
	if(reset)
	emptyFF<=1'd1;
	else
	begin
		if(setEmpty|resetEmpty)
		emptyFF<=~emptyFF;
	end
end

//rdptr
always @(posedge clock or posedge reset)
begin
	if(reset)
	rdptr<=3'd0;
	else
	begin
		if(incRDptr)
		rdptr<=rdptr+3'd1;
	end
end

//wrptr
always @(posedge clock or posedge reset)
begin
	if(reset)
	wrptr<=3'd0;
	else
	begin
		if(incWRptr)
		wrptr<=wrptr+3'd1;
	end
end

//decoder for write control
decode #(3) mydecoder1(wrctrl, wrptr);

//read into one of the 8 registers
always @(posedge clock&rd1&wrctrl[0])
data[0]<=ext1data; 
always @(posedge clock&rd2&wrctrl[0])
data[0]<=ext2data; 
always @(posedge clock&rd1&wrctrl[1])
data[1]<=ext1data;
always @(posedge clock&rd2&wrctrl[1])
data[1]<=ext2data; 
always @(posedge clock&rd1&wrctrl[2])
data[2]<=ext1data; 
always @(posedge clock&rd2&wrctrl[2])
data[2]<=ext2data; 
always @(posedge clock&rd1&wrctrl[3])
data[3]<=ext1data; 
always @(posedge clock&rd2&wrctrl[3])
data[3]<=ext2data; 
always @(posedge clock&rd1&wrctrl[4])
data[4]<=ext1data;
always @(posedge clock&rd2&wrctrl[4])
data[4]<=ext2data; 
always @(posedge clock&rd1&wrctrl[5])
data[5]<=ext1data;
always @(posedge clock&rd2&wrctrl[5])
data[5]<=ext2data; 
always @(posedge clock&rd1&wrctrl[6])
data[6]<=ext1data; 
always @(posedge clock&rd2&wrctrl[6])
data[6]<=ext2data; 
always @(posedge clock&rd1&wrctrl[7])
data[7]<=ext1data; 
always @(posedge clock&rd2&wrctrl[7])
data[7]<=ext2data; 

/*
//write to output register
mux8 #(8) mymux(port3_sender,{data[7],data[6],data[5],data[4],data[3],data[2],data[1],data[0]},rdptr);
//always @(posedge clock&wr)
//port3_sender<=data[rdptr];
*/

//decoder for read control
decode #(3) mydecoder2(rdctrl, rdptr);
always @(posedge clock&wr)
begin
	if(rdctrl[0])
	port3_sender<=data[0];
	else if(rdctrl[1])
	port3_sender<=data[1];
	else if(rdctrl[2])
	port3_sender<=data[2];
	else if(rdctrl[3])
	port3_sender<=data[3];
	else if(rdctrl[4])
	port3_sender<=data[4];
	else if(rdctrl[5])
	port3_sender<=data[5];
	else if(rdctrl[6])
	port3_sender<=data[6];
	else if(rdctrl[7])
	port3_sender<=data[7];
end 

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////arbitor
//the arbitor
//this arbitor gives each equal priority 
//(one external systems has the priority once and the other has the priority next time)
module arbitor(reset, clock, treq1, treq2, tgrant1, tgrant2);
input reset, clock, treq1, treq2;
output tgrant1, tgrant2;
reg [2:0]arbstate;

always @(posedge ~clock or posedge reset)
begin
	if(reset)
	arbstate<=3'b000;
	else
	begin
		if(arbstate==3'b000)
		begin
			if(treq1)
			arbstate<=3'b001;
			else if(~treq1&treq2)
			arbstate<=3'b010;
			else
			arbstate<=3'b000;
		end
		else if(arbstate==3'b001)
		begin
			if(treq1)
			arbstate<=3'b001;
			else
			arbstate<=3'b011;
		end
		else if(arbstate==3'b010)
		begin
			if(treq2)
			arbstate<=3'b010;
			else
			arbstate<=3'b011;
		end
		else if(arbstate==3'b011)
		begin
			if(treq2)
			arbstate<=3'b101;
			else if(~treq2&treq1)
			arbstate<=3'b100;
			else
			arbstate<=3'b011;
		end
		else if(arbstate==3'b100)
		begin
			if(treq1)
			arbstate<=3'b100;
			else
			arbstate<=3'b000;
		end
		else if(arbstate==3'b101)
		begin 
			if(treq2)
			arbstate<=3'b101;
			else
			arbstate<=3'b000;
		end
	end
end

//assign results of the arbitor
assign tgrant1=(arbstate==3'b001)|(arbstate==3'b100);
assign tgrant2=(arbstate==3'b010)|(arbstate==3'b101);
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////stateM1&2
module stateMachineSender(reset,clock, x, tgrant, dready,fullFF, emptyFF, dack, rd, incWRptr, setFull, resetEmpty, treq);
input reset,clock, x, tgrant, dready,fullFF, emptyFF;
output  dack, rd, incWRptr, setFull, resetEmpty, treq;
reg [2:0]senderState;
always@(posedge ~clock or posedge reset)
begin
	if(reset)
	senderState<=3'b000;
	else
	begin
		if(senderState==3'b000)
		begin
			if(fullFF|dready)
			senderState<=3'b000;
			else
			senderState<=3'b001;
		end
		else if(senderState==3'b001)
		begin
			if(~tgrant|fullFF)
			senderState<=3'b001;
			else
			senderState<=3'b010;
		end
		else if(senderState==3'b010)
		senderState<=3'b011;
		else if(senderState==3'b011)
		begin
			if(x)					//changed
			senderState<=3'b100;
			else if(~x&emptyFF)
			senderState<=3'b101;
			else
			senderState<=3'b110;
		end
	/*	//added state
		else if(senderState==3'b111)
		begin
			if(emptyFF)
			senderState<=3'b101;
			else
			senderState<=3'b100;
		end
		*/
		////////////////////////////
		else if(senderState==3'b100)
		begin
			if(emptyFF)
			senderState<=3'b101;
			else
			senderState<=3'b110;
		end
		else if(senderState==3'b101)
		senderState<=3'b110;
		else if(senderState==3'b110)
		begin
			if(~dready)
			senderState<=3'b110;
			else
			senderState<=3'b000;
		end
	end
end

//results
assign dack=(senderState==3'b000)|(senderState==3'b001)|(senderState==3'b010);
assign rd=(senderState==3'b010);
assign incWRptr=(senderState==3'b011);
assign setFull=(senderState==3'b100);
assign resetEmpty=(senderState==3'b101);
assign treq=(senderState==3'b001)|(senderState==3'b010)|(senderState==3'b011)|(senderState==3'b100)|(senderState==3'b101)|(senderState==3'b111);	

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////stateM3
module stateMachineRecevier(reset,clock, x, dreq,fullFF, emptyFF, dready, wr, incRDptr, setEmpty, resetFull);
input reset,clock,x, dreq,fullFF, emptyFF;
output dready, wr, incRDptr, setEmpty, resetFull;
reg [2:0]receiverState;
always@(posedge ~clock or posedge reset)
begin
	if(reset)
	receiverState<=3'b000;
	else
	begin
		if(receiverState==3'b000)
		begin
			if(emptyFF|dreq)
			receiverState<=3'b000;
			else
			receiverState<=3'b001;
		end
		else if(receiverState==3'b001)
		receiverState<=3'b010;
		else if(receiverState==3'b010)
		begin
			if(x)						//changed 
			receiverState<=3'b011;
			else if(~x&fullFF)
			receiverState<=3'b100;
			else
			receiverState<=3'b101;
		end
		/*//added state
		else if(receiverState==3'b111)
		begin
			if(fullFF)						//changed 
			receiverState<=3'b100;
			else
			receiverState<=3'b011;
			//??
		end*/
		//////////////////////////////
		else if(receiverState==3'b011)
		begin
			if(fullFF)
			receiverState<=3'b100;
			else
			receiverState<=3'b101;
		end
		else if(receiverState==3'b100)
		receiverState<=3'b101;
		else if(receiverState==3'b101)
		begin
			if(~dreq)
			receiverState<=3'b101;
			else
			receiverState<=3'b000;
		end
	end
end

//assign results
assign dready=(receiverState==3'b000)|(receiverState==3'b001);
assign wr=(receiverState==3'b001);
assign incRDptr=(receiverState==3'b010);
assign setEmpty=(receiverState==3'b011);
assign resetFull=(receiverState==3'b100);
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////extRecevier
module extReceiver(clock, reset, dready, datain, dreq);
//inputs and outputs and the register for the whole external receiver architecture
input clock, reset, dready;
input [7:0]datain;
output dreq;
wire rd;
reg [7:0]ext3data;

//variables for statemachine
reg [1:0]state;

//statemachine
always@ (posedge ~clock or posedge reset)
begin 
	if(reset)
	state<=2'b00;
	else
	begin
		if(state==2'b00)
			begin
				if(dready)
				state<=2'b01;
				//
				else
				state<=2'b00;
			end
		else if(state==2'b01)
			begin
				if(~dready)
				state<=2'b10;
				//
				else
				state<=2'b01;
			end
		else if(state==2'b10)
			state<=2'b00;
	end
end

//assigning result of dreq and rd according to the state value
assign dreq=(state==2'b00);
assign rd=(state==2'b10);

//read data input
always @(posedge clock&rd)
ext3data<=datain;

endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////extSender
module extSender(clk, reset, dack, dready, wr);
//inputs and outputs and the register for the whole external sender architecture
input clk, reset, dack;
//input [7:0]datain;
output dready,wr; 
wire wr;
//reg [7:0]data;
//wire data;
//variables for statemachine
reg [1:0]state;

//statemachine
always@ (posedge ~clk or posedge reset)
begin 
	if(reset)
	state<=2'b00;
	else
	begin
		if(state==2'b00)
			begin
				if(dack)
				state<=2'b01;
				//
				else
				state<=2'b00;
			end
		else if(state==2'b01)
			state<=2'b10;
		else if(state==2'b10)
			begin
				if(~dack)
				state<=2'b00;
				//
				else
				state<=2'b10;
			end
		
	end
end

//assigning result of dready and wr according to the state value
assign dready=(state==2'b00)|(state==2'b01);
assign wr=(state==2'b01);

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////clocks

//The clock module
module clocks(reset, clk1, clk2, clk3, clk4);
   // provides a reset signal and four independent clocks
   output reset, clk1, clk2, clk3, clk4;
   reg clk1, clk2, clk3, clk4;
   reg [8:0] X;
   wire clk;
   
   init clocks_init(reset, clk);
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  X <= 9'd1;
	  clk1 <= 1'd0;
	  clk4 <= 1'd0;
       end
     else
       begin
	  clk1 <= X[1] & X[3];
	  clk4 <= X[4] & X[6] & ~X[7];
	  X <= {X[7:0], 1'b0}^{4'b0000, X[8], 3'b000, X[8]};
	// corresponds to primitive polynomial
	// x^9 + x^4 + 1
       end
   always @(posedge ~clk or posedge reset)
     if (reset)
       begin
	  clk2 <= 1'd0;
	  clk3 <= 1'd0;
       end
     else
       begin
	  clk2 <= X[1] & ~X[2] & ~X[4];
	  clk3 <= X[0] & ~X[5];
       end
   
endmodule // clocks

/*
//////////////////?~~~~~~~~~~~~~~~~~~~~test clocks for full
//The clock module
module clocks(reset, clk1, clk2, clk3, clk4);
   // provides a reset signal and four independent clocks
   output reset, clk1, clk2, clk3, clk4;
   reg clk1, clk2, clk3, clk4;
   reg [2:0] X;
   wire clk;
   
   init clocks_init(reset, clk);
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  X <= 3'd0;
	  clk1 <= 1'd0;
	  clk4 <= 1'd0;
	clk2<=1'd0;
	clk3<=1'd0;
       end
     else
       begin
	  clk1 <= X[0];
	  clk2 <= clk1;
	  clk4 <= X[1];
	  X <= X+3'd1;
       end
   
endmodule // clocks
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////test
module test_proj3;         // test bench for the module proj3
wire reset, ext1clk,ext2clk,ext3clk,fifo_clk;
wire dack1, dack2, dready1, dready2, dready3, dreq3, wr1, wr2;
wire dack;
reg[7:0]ext1data, ext2data;
wire [7:0]port3_sender;
reg eof1, eof2;
integer data_file1, data_file2;
//test
assign dack=dack1&dack2;

initial
begin
	data_file1 = $fopen("proj3A.dat", "rb");
	data_file2 = $fopen("proj3B.dat", "rb");
end

//initiate clocks
clocks my_clocks(reset,  fifo_clk, ext2clk, ext1clk, ext3clk );
//external System1
extSender ext1(ext1clk, reset, dack1, dready1, wr1);
//readfile for external system1
always @(posedge ext1clk&wr1)
    begin
      eof1 = $feof(data_file1);
      if (eof1 == 0)
         $fscanf(data_file1, "%d",ext1data);
      else
        begin
         $fclose(data_file1);
         $finish;
        end
    end

//external System2
extSender ext2(ext2clk, reset, dack2, dready2, wr2);
//readfile for external system2
always @(posedge ext2clk&wr2)
    begin
      eof2 = $feof(data_file2);
      if (eof2 == 0)
         $fscanf(data_file2, "%d",ext2data);
      else
        begin
         $fclose(data_file2);
         $finish;
        end
    end




//externa System3
extReceiver ext3(ext3clk, reset, dready3, port3_sender, dreq3);
//FIFO
proj3 my_FIFO(fifo_clk, reset, dready1, dready2, dreq3, ext1data, ext2data, dack1, dack2, dready3, port3_sender);
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////







