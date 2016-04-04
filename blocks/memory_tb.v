`timescale 1ns / 1ps


`define WORD 2'b10
`define BYTE 2'b00
`define HALF_WORD 2'b01
module memory_tb;

	// Inputs
	reg clk;
	reg rst;
	reg wr_en;
	reg [31:0] address;
	reg [31:0] in_val;
	reg [1:0] mem_size;
	reg sz_ex;

	// Outputs
	wire [31:0] out_val;
	wire [31:0] mem_map_io;

	// Instantiate the Unit Under Test (UUT)
	memory uut (
		.clk(clk), 
		.rst(rst), 
		.wr_en(wr_en), 
		.address(address), 
		.in_val(in_val), 
		.mem_size(mem_size), 
		.sz_ex(sz_ex), 
		.out_val(out_val),
		.mem_map_io(mem_map_io)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		wr_en = 0;
		address = 0;
		in_val = 0;
		mem_size = 0;
		sz_ex = 0;

		// Wait 100 ns for global reset to finish
		#10;
      $monitor($time , " clk %d, rst %d, wr_en %d, address %x, in_val %b, mem_size %d, sz_ex %d, out_val %b mem_map_io %b",
                 clk,rst,wr_en,address , in_val,mem_size,sz_ex,out_val,mem_map_io);		
		// Add stimulus here
		
		rst = 1'b1 ;
		#10 address = 4 ;
		#10 address = 8 ;
		#10 rst = 1'b0 ;
		
		#10 ;
		wr_en = 1'b1 ;
		address = 0 ;
		mem_size = `WORD ;
		in_val = 32'hFF00FF00 ;
		
		#10 ; 
		wr_en= 1'b0 ;
		address = 0 ;
		mem_size = `WORD ;
		
		#10 ; 
		wr_en= 1'b1 ;
		address = 128 ;
		sz_ex = 1'b1 ;
		mem_size = `HALF_WORD ;
		in_val = 32'h00FF00FF ;
		
		#10 ; 
		wr_en= 1'b0 ;
		address = 36 ;
		sz_ex = 1'b1 ;
		mem_size = `BYTE ;
		
		#10 ;   
		rst = 1'b0;
		

	end
      
		
		always begin
		#10 clk =~clk;
		end
endmodule

