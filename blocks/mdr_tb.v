`timescale 1ns / 1ps

module mdr_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] data_in;
	reg load_mdr;

	// Outputs
	wire [31:0] data_out;

	// Instantiate the Unit Under Test (UUT)
	mdr uut (
		.data_out(data_out), 
		.clk(clk), 
		.rst(rst), 
		.data_in(data_in), 
		.load_mdr(load_mdr)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		data_in = 0;
		load_mdr = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		$monitor("data_in = %x, load_mdr = %b, data_out = %x", data_in, load_mdr, data_out);
		
		#5;
		//rest the design
		rst = 1'b1;
		#30;
		rst = 1'b0;
		
		//provide test input
		data_in = 32'h0000FFFF;
		load_mdr = 1'b1;
		#20;
		load_mdr = 1'b0;
		
		//terminate simulation
		#100;
		$finish;

	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end
      
endmodule

