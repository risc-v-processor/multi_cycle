`timescale 1ns / 1ps

//macros
//if BIT_WIDTH is set to n, a clock frequency of 50MHz / 2^n is generated
`define BIT_WIDTH 20
//clock rate = 50MHz / 2^20 = 47.68 Hz

module clock_gen (
	output clk_d,
	input rst,
	input clk
    );

	reg [(`BIT_WIDTH-1) : 0] ctr;
	assign clk_d = ctr[`BIT_WIDTH-1];
	
	always @ (posedge clk)
	begin
		if (rst)
		begin
			ctr <= {`BIT_WIDTH{1'b0}};
		end
		
		else
		begin
			ctr <= ctr + 1'b1;
		end
	end

endmodule
