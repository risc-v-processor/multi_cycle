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
        $monitor ($time, " :  state = %d, curr_addr = %x, next_addr = %x, sz_ex_out = %x, alu_ctrl = %b\
mem_map_io = %d, mem_wr_en = %b, reg_data_2 = %d, reg2 = %d, register2-data = %d", 
			uut.cntl_mc_inst.state, uut.curr_addr, uut.alu_demux_0, uut.sz_ex_out, uut.alu_ctrl,
			uut.mem_map_io, uut.mem_wr_en, uut.reg_data_2, uut.reg2, uut.reg_file_inst.reg_array[2]);
        
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

