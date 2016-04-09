`timescale 1ns / 1ps

module cntl_mc_tb;

	// Inputs
	reg [31:0] inst;
	reg bcond;
	reg clk;
	reg rst;

	// Outputs
	wire sz_ex_sel;
	wire [1:0] sz_ex_mode;
	wire mem_sz_ex_sel;
	wire [19:0] imm;
	wire mem_sel;
	wire [1:0] mem_size;
	wire pc_update;
	wire load_ir;
	wire load_mdr;
	wire mem_wr_en;
	wire reg_file_wr_en;
	wire wr_reg_mux_sel;
	wire op1_sel;
	wire [1:0] op2_sel;
	wire [1:0] alu_demux;
	wire [4:0] alu_ctrl;

	// Instantiate the Unit Under Test (UUT)
	cntl_mc uut (
		.inst(inst), 
		.bcond(bcond), 
		.clk(clk), 
		.rst(rst), 
		.sz_ex_sel(sz_ex_sel), 
		.sz_ex_mode(sz_ex_mode), 
		.mem_sz_ex_sel(mem_sz_ex_sel), 
		.imm(imm), 
		.mem_sel(mem_sel), 
		.mem_size(mem_size), 
		.pc_update(pc_update), 
		.load_ir(load_ir), 
		.load_mdr(load_mdr), 
		.mem_wr_en(mem_wr_en), 
		.reg_file_wr_en(reg_file_wr_en), 
		.wr_reg_mux_sel(wr_reg_mux_sel), 
		.op1_sel(op1_sel), 
		.op2_sel(op2_sel), 
		.alu_demux(alu_demux), 
		.alu_ctrl(alu_ctrl)
	);

	initial begin
		// Initialize Inputs
		inst = 0;
		bcond = 0;
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#5;
		//reset the design
		rst = 1'b1;
		#20;
		rst = 1'b0;
		
		//provide an instruction input
		inst = 32'b00000000000000000000000000110100;
		
		//terminate simulation
		#30;
		$finish;

	end
	
	always begin
		//generate clock signal
		#10 clk = ~clk;
	end   
 
endmodule

