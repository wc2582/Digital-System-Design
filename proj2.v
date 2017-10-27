//ECE319
//Project 2
//Weihe Chen
//wec217
//Project description: this project implements a part of 8085
//			microprocessor instructions

	module test(reset, clock, address, data, rd, wr);
	
	//inputs and outputs
	input clock, reset;
	output wr, rd;
	output [15:0]address;
	inout[7:0] data;
	tri[7:0]data;

	reg [1:0] step;
	wire wr, rd, mov, mvi, add, sub, lda, sta, lxi, hlt, nop, cout, cir, ctempu, ctempl, cpc,m;
	wire ta, tb, tc, td, te, th, tl, ca, cb, cc, cd, ce, ch, cl;

	//wire[1:0]cmux;
	wire [7:0]src, dest, sum, rxor;
	wire [3:0]opcode;
	//ftri [7:0]data;
	reg [7:0]a, b, c, d, e, h, l, ir, tempu, templ;
	reg [15:0]pc;
	wire [15:0]mux1out;

	//calculate one of the input of A register (when doing add or sub)
	xorgate #(8) myxor(rxor, sub, data);
	cpa #(8) mycpa(sum, cout, a, rxor, sub);

	//////////////////////////////////////////////////////////////////////////////////////
	//describe registers to data with tristate selection
	tristate #(8) tristate1(data, a, ta); //register A
	tristate #(8) tristate2(data, b, tb); //register B
	tristate #(8) tristate3(data, c, tc); //register C
	tristate #(8) tristate4(data, d, td); //register D
	tristate #(8) tristate5(data, e, te); //register E
	tristate #(8) tristate6(data, h, th); //register H
	tristate #(8) tristate7(data, l, tl); //register L

	//describe data to registers and IR with controls
	always@(posedge clock&ca)
	begin
		if(add|sub)
			a<=sum;
		else
			a<=data;
	end
	always@(posedge clock&cb)
		b<=data;
	always@(posedge clock&cc)
		c<=data;
	always@(posedge clock&cd)
		d<=data;
	always@(posedge clock&ce)
		e<=data;
	always@(posedge clock&ch)
		h<=data;
	always@(posedge clock&cl)
		l<=data;
	always@(posedge clock&cir or reset)
		ir<=data;
	always@(posedge clock&ctempu)
		tempu<=data;
	always@(posedge clock&ctempl)
		templ<=data;
	//////////////////////////////////////////////////////////////////////////////////////
	//decode opcode, destination  and source in IR
	decode #(2) mydecoder1(opcode, ir[7:6]);
	decode #(3) mydecoder2(dest, ir[5:3]);
	decode #(3) mydecoder3(src, ir[2:0]);
	//////////////////////////////////////////////////////////////////////////////////////
	//program counter
	always@(negedge clock or posedge reset)
	begin
		if(reset)
			pc<=16'd0;
		else if(cpc)
			pc<=pc+16'd1;
	end
	//////////////////////////////////////////////////////////////////////////////////////
	//choice of address
	//mux4 #(16) mymux(address, {16'd0, {h, l},{tempu, templ}, pc},cmux);
	mux2 #(16) mux1(mux1out, {{h, l},{tempu,templ}},m);
	mux2 #(16) mux2(address, {pc, mux1out}, cpc);
	//////////////////////////////////////////////////////////////////////////////////////
	//step counter for control
	always @(negedge clock or posedge reset)
	begin
	       if(reset)
			step<=2'd0;
		else
		begin
		if(nop)
			step<=2'd0;
		else if(hlt)
			step<=2'd1;
		else if(((mov|mvi|add|sub)&(step==2'd1))|(lxi&(step==2'd2)))
			step<=2'd0;
		else 
			step<=step+2'd1;
		end
	end
	//always @(posedge clock)
	//	step<=stephf;
	
	//////////////////////////////////////////////////////////////////////////////////////
	//assignment of instruction types
	assign mov=opcode[1];
	assign hlt=opcode[1]&dest[6]&src[6];
	assign add=opcode[2]&dest[0];
	assign sub=opcode[2]&dest[2];
	assign sta=opcode[0]&dest[6]&src[2];
	assign lda=opcode[0]&dest[7]&src[2];
	assign mvi=opcode[0]&(~dest[6])&src[6];
	assign lxi=opcode[0]&(~dest[6])&src[1];
	assign nop=opcode[0]&dest[0]&src[0];

	//assignment of controls
	assign cir=(step==2'd0);							//IR
	assign ctempu=(sta|lda)&(step==2'd2);						//temporary register upper
	assign ctempl=(sta|lda)&(step==2'd1);						//temporary register lower
	assign m=(mov&(dest[6]|src[6]))|((add|sub)&src[6])|reset;			//choose hl for 1
	assign cpc=~(((mov|sub|add)&(step==2'd1))|((lda|sta)&(step==2'd3)))|reset;	//program counter 	
	assign rd=(~wr)|ta|tb|tc|td|te|th|tl|(hlt&step==2'd1);				//rd active low
	assign wr=~(((mov&dest[6]&(step==2'd1))|sta&(step==2'd3))&(clock))|(hlt&step==2'd1);		//write active low
	
	//control for registers
	assign ta= ((mov|add|sub)&(step==2'd1)&src[7])|(sta&(step==2'd3)); 
	assign tb= (mov|add|sub)&(step==2'd1)&src[0];
	assign tc= (mov|add|sub)&(step==2'd1)&src[1];
	assign td= (mov|add|sub)&(step==2'd1)&src[2];
	assign te= (mov|add|sub)&(step==2'd1)&src[3];
	assign th= (mov|add|sub)&(step==2'd1)&src[4];
	assign tl= (mov|add|sub)&(step==2'd1)&src[5];

	assign ca= ((((mov|mvi)&dest[7])|add|sub)&(step==2'd1))|(lda&(step==2'd3));
	assign cb= ((mov|mvi)&(step==2'd1)&dest[0])|(lxi&(step==2'd2)&dest[0]);
	assign cc= ((mov|mvi)&(step==2'd1)&dest[1])|(lxi&(step==2'd1)&dest[0]);
	assign cd= ((mov|mvi)&(step==2'd1)&dest[2])|(lxi&(step==2'd2)&dest[2]);
	assign ce= ((mov|mvi)&(step==2'd1)&dest[3])|(lxi&(step==2'd1)&dest[2]);
	assign ch= ((mov|mvi)&(step==2'd1)&dest[4])|(lxi&(step==2'd2)&dest[4]);
	assign cl= ((mov|mvi)&(step==2'd1)&dest[5])|(lxi&(step==2'd1)&dest[4]);

	endmodule


	// Test bench for Project II
	// contains 1KByte memory (1024 8-bit words), active low rd and wr signals


	module test_test;       	 	 // test bench for the module cpu
	wire reset, clock;      		 // reset and clock inputs to cpu
	wire [15:0] address;    		 // 16 address lines from cpu
	tri [7:0] data;        			 // 8 bidirectional data lines from cpu
	wire rd, wr;           			 // rd and wr signals from cpu for memory
	wire [9:0] ram_address;
			   
	reg [7:0] ram_mem[0:1023]; 		// we only implement 1 KByte memory in the
						// test bench, even if CPU can address 64 KBytes

	/* MEMORY */
	assign   ram_address = address[9:0];  // use only 10 bit address for ram
			   
	// output data when rd is low (logic 0)
	// (rd is active low: normal state = logic 1)
	tristate #(8) ram_tristate(data, ram_mem[ram_address], ~rd);

	// write data to memory at the end of low pulse on wr 
	// (wr is active low: normal state = logic 1)
	always @(posedge wr)
	ram_mem[ram_address] <= data;

	initial
	$readmemh("Proj2.dat", ram_mem);

	/* GENERATE CLOCK AN RESET FOR THE CPU */
	init test_init(reset, clock);

	/* INSTANTIATE cpu */ 
	test my_cpu(reset, clock, address, data, rd, wr);
			   
	endmodule
