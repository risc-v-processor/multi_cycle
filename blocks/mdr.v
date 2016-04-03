//memory data register

//macros
`define BUS_WIDTH 32

module mdr(
	//Outputs
	//data output
	output [(`BUS_WIDTH-1):0] data_out,
	//Inputs
	//clock
	input clk,
	//reset
	input rst,
	//data input
	input [(`BUS_WIDTH-1):0] data_in,
	//load MDR signal
	input load_mdr
);

	//register to hold the data
	reg [(`BUS_WIDTH-1):0] data;
	
	//connect the output signal
	assign data_out[(`BUS_WIDTH-1):0] = data[(`BUS_WIDTH-1):0];
	
	//combinational logic
	always @ (negedge clk) begin
		//check reset signal
		if (rst == 1'b1) begin
			data[(`BUS_WIDTH-1):0] <= 32'b0;
		end
		//check load_mdr signal
		else begin
			if (load_mdr == 1'b1) begin
				data[(`BUS_WIDTH-1):0] <= data_in[(`BUS_WIDTH-1):0];
			end
		end
	end
	
endmodule
