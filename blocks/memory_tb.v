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

module memory_tb;

	// Inputs
	reg clk;
	reg rst;
	reg wr_en;
	reg [31:0] address;
	reg [31:0] in_val;
	reg [1:0] mem_size;
	reg mem_sz_ex_sel;

	// Outputs
	wire [31:0] mem_map_io;
	wire [31:0] out_val;

	// Instantiate the Unit Under Test (UUT)
	memory uut (
		.mem_map_io(mem_map_io), 
		.out_val(out_val), 
		.clk(clk), 
		.rst(rst), 
		.wr_en(wr_en), 
		.address(address), 
		.in_val(in_val), 
		.mem_size(mem_size), 
		.mem_sz_ex_sel(mem_sz_ex_sel)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		wr_en = 0;
		address = 0;
		in_val = 0;
		mem_size = 0;
		mem_sz_ex_sel = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		$monitor("out_val = %x, mem_map_io = %x", out_val, mem_map_io);
		
		#10;
		
		//reset
		rst = 1'b1;
		#20
		rst = 1'b0;
		
		//read data from memory
		#5;
		address = 0;

		//write data into memory
		#20;
		wr_en = 1'b1;
		address = 65;
		mem_size = `BYTE;
		in_val = 32'h0000FFFF;
		
		//write to illegal location (instruction memory)
		#20;
		wr_en = 1'b1;
		address = 4;
		mem_size = `WORD;
		in_val = 32'h0000FFFF;
				
		//read out the value to check if the data is corrupted
		#20;
		wr_en = 1'b0;
		address = 4;
		mem_size = `WORD;

		//write to memory mapped I/O
		#20;
		wr_en = 1'b1;
		address = 128;
		mem_size = `BYTE;
		in_val = 32'h0000FFFF;
		
		//read another location in memory
		#20;
		wr_en = 1'b0;
		address = 8;
		mem_size = `WORD;			
		
		//terminate simulation
		#30;
		$finish;
		
	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end
      
endmodule

