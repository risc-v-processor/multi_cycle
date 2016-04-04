`timescale 1ns / 1ps

//macros
`define BUS_WIDTH 32
`define I_MEM_SIZE 64
`define MEM_MAP_IO_ADDRESS 128

module memory(
	//Outputs
	//memory mapped I/O
	output reg [(`BUS_WIDTH-1):0] mem_map_io,
	//value read from memory
	output [(`BUS_WIDTH-1):0] out_val,
	//Inputs	
	//clock
	input clk,
	//reset
	input rst,
	//write enable
	input wr_en,
	//memory address
	input [(`BUS_WIDTH-1):0] address,
	//input value to be written to memory
	input [(`BUS_WIDTH-1):0] in_val,
	//size of memory to access or write to
	input [1:0] mem_size,
	//sign or zero extend
	input mem_sz_ex_sel
);

	//memory write enable signal
	reg mem_wr_en;
	
	mem mem_inst (
		.clk(clk),
		.rst(rst),
		.data_out(out_val),
		.mem_size(mem_size),
		.sz_ex(mem_sz_ex_sel),
		.wr_en(mem_wr_en),
		.address(address),
		.data_in(in_val)
	);
	
	//combinational logic
	//set the memory write enable signal to the appropriate value
	always @ (*) begin
		if (address < `I_MEM_SIZE) begin
			mem_wr_en = 1'b0;
		end
		
		else begin
			mem_wr_en = wr_en;
		end
	end
	
	//sequential logic	
	//handle reset signal and write to mem_map_io
	always@(negedge clk) begin
		//check if reset signal is set
		if (rst == 1'b1) begin
			mem_map_io <= 32'b0;
		end
		
		//check if address belongs to memory mapped I/O
		else if((address == `MEM_MAP_IO_ADDRESS) && (wr_en == 1'b1)) begin
			mem_map_io <= in_val;
		end
	end
			
endmodule
