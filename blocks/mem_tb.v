`timescale 1ns / 1ps

//macros
//Bus width
`define BUS_WIDTH 32
//2 Kb memory
//Byte addressable memory
//Memory vector size = 2048/8 = 256
`define MEM_VECTOR_SIZE 256
//memory size
//word (32 bits)
`define WORD 2'b10
//half word (16 bits)
`define HALF_WORD 2'b01
//byte (8 bits)
`define BYTE 2'b00

module mem_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] address;
	reg [31:0] data_in;
	reg wr_en;
	reg [1:0] mem_size;
	reg sz_ex;

	// Outputs
	wire [31:0] data_out;

	// Instantiate the Unit Under Test (UUT)
	mem uut (
		.data_out(data_out), 
		.clk(clk), 
		.rst(rst), 
		.address(address), 
		.data_in(data_in), 
		.wr_en(wr_en), 
		.mem_size(mem_size), 
		.sz_ex(sz_ex)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		address = 0;
		data_in = 0;
		wr_en = 0;
		mem_size = `WORD;
		sz_ex = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		$monitor($time, "\t data_out = %d,    address = %d,    data_in = %d,    wr_en = %b,    mem_size = %b, sz_ex = %b",
				 data_out, address, data_in, wr_en, mem_size, sz_ex);

		//reset
		rst = 1'b1;
		#20
		rst = 1'b0;
		$display ($time);
		
		
		//write data into memory
		#5;
		wr_en = 1'b1;
		address = 0;
		data_in = 32'h000000FF;
		
		#20;
		wr_en = 1'b1;
		address = 4;
		mem_size = `BYTE;
		data_in = 32'h0000FFFF;
		
		#20;
		wr_en = 1'b1;
		address = 8;
		mem_size = `WORD;
		data_in = 32'h00FFFFFF;
		
		//read back the values
		//read the sign extended byte value at address = 0
		#20;
		wr_en = 1'b0;
		address = 0;
		mem_size = `BYTE;
		sz_ex = 1'b1;
		
		//read the zero extended half word value at address = 4
		#20;
		address = 4;
		mem_size = `HALF_WORD;
		sz_ex = 1'b0;
		
		//write a value to memory 
		#20;
		address = 12;
		mem_size = `WORD;
		wr_en = 1'b1;
		data_in = 32'hFFFFFFFF;
		
		//read back the unsigned half word value
		#20;
		mem_size = `HALF_WORD;
		wr_en = 1'b0;		 
				 
		//terminate simulation
		#30;
		$finish;
		
	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end
      
endmodule
