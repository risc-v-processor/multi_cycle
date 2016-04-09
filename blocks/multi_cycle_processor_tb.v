`timescale 1ns / 1ps

module mutli_cycle_processor_tb;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire [31:0] mem_map_io;

	// Instantiate the Unit Under Test (UUT)
	multi_cycle_processor uut (
		.mem_map_io(mem_map_io), 
		.rst(rst), 
		.clk(clk)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		//reset the design
		#5;
		rst = 1'b1;
		#10;
		rst = 1'b0;
		#100;
		$finish;
	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end
      
endmodule

