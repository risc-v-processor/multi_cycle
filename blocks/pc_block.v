`timescale 1ns / 1ps

//macros
`define BUS_WIDTH 32

module pc_block(
	//inputs
	//reset
   input rst,
   //clock
   input clk,
	//update signal
	input PC_Update,
   //next address 
	input [(`BUS_WIDTH-1):0] next_addr,
	//current address
	output reg [(`BUS_WIDTH-1):0] curr_addr 
);

	//sequential logic
	always @(posedge clk) begin
		if (rst == 1'b1) begin
			curr_addr <= {`BUS_WIDTH{1'b0}};
		end
		
		else if (PC_Update == 1'b1) begin		
			curr_addr <= next_addr;
		end
	end	 
	 
endmodule
