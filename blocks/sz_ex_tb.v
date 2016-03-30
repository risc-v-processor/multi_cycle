`timescale 1ns / 1ps

//macros
//sign or zero extend mode
//12 bits to 32 bits (sign or zero extend)
`define STANDARD 2'b00
//immediate(12 bits) is a multiple of 2 bytes (BRANCH)
`define BRANCH 2'b01
//immediate constitutes the MSB bits of an operand (U_TYPE)
`define U_TYPE 2'b10
//immediate(20 bits) is a multiple of 2 bytes (JAL)
`define JAL 2'b11

module sz_ex_tb;

	// Inputs
	reg sz_ex_sel;
	reg [1:0] sz_ex_mode;
	reg [19:0] imm;

	// Outputs
	wire [31:0] sz_ex_out;

	// Instantiate the Unit Under Test (UUT)
	sz_ex uut (
		.sz_ex_out(sz_ex_out), 
		.sz_ex_sel(sz_ex_sel), 
		.sz_ex_mode(sz_ex_mode), 
		.imm(imm)
	);

	initial begin
		// Initialize Inputs
		sz_ex_sel = 0;
		sz_ex_mode = 0;
		imm = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		//monitor values of signals
		$monitor("imm = %x, sz_ex_sel = %b, sz_ex_mode = %b, sz_ex_out = %x", imm, sz_ex_sel, sz_ex_mode, sz_ex_out);
		
		sz_ex_mode = `STANDARD;
		imm = 20'h00FFF;
		//zero extend
		sz_ex_sel = 1'b0;
		#10;
		//sign extend
		sz_ex_sel = 1'b1;
		#10;
		
		sz_ex_mode = `BRANCH;
		imm = 20'h00FFF;
		//zero extend
		sz_ex_sel = 1'b0;
		#10;
		//sign extend
		sz_ex_sel = 1'b1;
		#10;		
		
		sz_ex_mode = `U_TYPE;
		imm = 20'hFFFFF;
		//zero extend
		sz_ex_sel = 1'b0;
		#10;
		//sign extend
		sz_ex_sel = 1'b1;
		#10;
		
		sz_ex_mode = `JAL;
		imm = 20'hFFFFF;
		//zero extend
		sz_ex_sel = 1'b0;
		#10;
		//sign extend
		sz_ex_sel = 1'b1;
		#10;
		
		//terminate simulation
		$finish;
		
	end
      
endmodule

