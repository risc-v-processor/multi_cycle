`timescale 1ns / 1ps

module ir_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] inst_in;
	reg load_ir;

	// Outputs
	wire [4:0] reg1;
	wire [4:0] reg2;
	wire [4:0] dest;
	wire [31:0] inst_out;

	// Instantiate the Unit Under Test (UUT)
	ir uut (
		.reg1(reg1), 
		.reg2(reg2), 
		.dest(dest), 
		.inst_out(inst_out), 
		.clk(clk), 
		.rst(rst), 
		.inst_in(inst_in), 
		.load_ir(load_ir)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		inst_in = 0;
		load_ir = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		$monitor("load_ir = %b, inst_in = %x, reg1 = %d, reg2 = %d, dest = %d, inst_out = %x", load_ir,
					inst_in , reg1, reg2, dest, inst_out);
					
		#5;
		
		//rest the design
		rst = 1'b1;
		#30;
		rst = 1'b0;
		
		//provide test input
		//store r2 to address 64 (SW r0, r2, 64)
		inst_in = 32'h04202023;
		load_ir = 1'b1;
		#20;
		load_ir = 1'b0;
		
		//provide another test input
		#10;
		inst_in = 32'h00110113;
		load_ir = 1'b1;
		#20;
		load_ir = 1'b0;		
		
		//terminate simulation
		#100;
		$finish;

	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end
      
endmodule

