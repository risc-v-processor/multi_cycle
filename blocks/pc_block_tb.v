`timescale 1ns / 1ps

module pc_block_tb;

	// Inputs
	reg rst;
	reg clk;
	reg PC_Update;
	reg [31:0] next_addr;

	// Outputs
	wire [31:0] curr_addr;

	// Instantiate the Unit Under Test (UUT)
	pc_block uut (
		.rst(rst), 
		.clk(clk), 
		.PC_Update(PC_Update),
		.next_addr(next_addr), 
		.curr_addr(curr_addr)
	);

	initial begin
		$monitor($time, " reset = %b, PC_Update = %b, current address = %d, next address = %d", rst, PC_Update, curr_addr, next_addr);
		// Initialize Inputs
		rst = 0;
		clk = 0;
		PC_Update = 0;
		
		// Wait 100 ns for global reset to finish
		#100; 
		
		// Add stimulus here
		//rest design
		rst = 1;      
		
		#100;
		rst = 0;
		
		//set value of next_addr
		next_addr = 32'h4444;
		#30;
		//set PC_Update signal
		PC_Update = 1'b1;
		#100;
		//reset PC_Update signal
		PC_Update = 1'b0;
		#50;
		//change value of next_addr
		next_addr = 32'h5555;
		//terminate simulation
		#200;  
		$finish; 
		
	end
	
	always begin
		#50 clk = !clk ;
	end

endmodule
