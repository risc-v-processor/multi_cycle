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
	reg [31:0] in_data;
	reg [1:0] mem_size;
	reg sz_ex;

	// Outputs
	wire [31:0] out_data;
	wire [31:0] mem_map_io;

	// Instantiate the Unit Under Test (UUT)
	memory uut (
		.clk(clk), 
		.rst(rst), 
		.wr_en(wr_en), 
		.address(address), 
		.in_data(in_data), 
		.mem_size(mem_size), 
		.sz_ex(sz_ex), 
		.out_data(out_data),
		.mem_map_io(mem_map_io)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		wr_en = 0;
		address = 0;
		in_data = 0;
		mem_size = 0;
		sz_ex = 0;

		// Wait 100 ns for global reset to finish
		#10;
      $monitor($time , " clk %d, rst %d, wr_en %d, address %x, in_data %b, mem_size %d, sz_ex %d, out_data %b mem_map_io %b",
                 clk,rst,wr_en,address , in_data,mem_size,sz_ex,out_data,mem_map_io);		
		// Add stimulus here
		
		rst = 1'b1 ;
		#10 address = 4 ;
		#10 address = 8 ;
		#10 rst = 1'b0 ;
		
		#10 ;
		wr_en = 1'b1 ;
		address = 0 ;
		mem_size = `WORD ;
		in_data = 32'hFF00FF00 ;
		
		#10 ; 
		wr_en= 1'b0 ;
		address = 0 ;
		mem_size = `WORD ;
		
		#10 ; 
		wr_en= 1'b1 ;
		address = 128 ;
		sz_ex = 1'b1 ;
		mem_size = `HALF_WORD ;
		in_data = 32'h00FF00FF ;
		
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

