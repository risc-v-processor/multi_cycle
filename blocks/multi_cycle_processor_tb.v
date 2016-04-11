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
        
        //monitor signals
        $monitor ($time, " :  state = %d, curr_addr = %x, alu_ctrl = %b, ALU_out = %d, wr_reg_data = %d,\
reg1 = %d, op1_sel = %b, op2_sel = %b, Operand1 = %d, Operand2 = %d, reg2_data = %d, wr_reg_mux_sel = %b", 
			uut.cntl_mc_inst.state, uut.curr_addr, uut.alu_ctrl, uut.wr_reg_data, uut.Out, uut.reg1, uut.op1_sel, 
			uut.op2_sel, uut.Operand1, uut.Operand2, uut.reg_file_inst.reg_array[2], uut.wr_reg_mux_sel);
        
		// Add stimulus here
		//reset the design
		#5;
		rst = 1'b1;
		#20;
		rst = 1'b0;
		
		//terminate simulation
		#100;
		$finish;
	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end
      
endmodule
