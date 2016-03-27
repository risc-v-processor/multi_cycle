`timescale 1ns / 1ps

//macros
//Register file properties
`define REGISTER_COUNT 32
`define REGISTER_WIDTH 32
//5 bits required to address 32 registers
`define REG_INDEX_WIDTH 5

module reg_file_tb;

	// Inputs
	reg rst;
	reg wr_en;
	reg clk;
	reg [(`REG_INDEX_WIDTH-1):0] rd_reg_index_1;
	reg [(`REG_INDEX_WIDTH-1):0] rd_reg_index_2;
	reg [(`REG_INDEX_WIDTH-1):0] wr_reg_index;
	reg [(`REGISTER_WIDTH-1):0] wr_reg_data;

	// Outputs
	wire [(`REGISTER_WIDTH-1):0] reg_data_1;
	wire [(`REGISTER_WIDTH-1):0] reg_data_2;

	// Instantiate the Unit Under Test (UUT)
	reg_file uut (
		.reg_data_1(reg_data_1), 
		.reg_data_2(reg_data_2), 
		.rst(rst), 
		.wr_en(wr_en), 
		.clk(clk), 
		.rd_reg_index_1(rd_reg_index_1), 
		.rd_reg_index_2(rd_reg_index_2), 
		.wr_reg_index(wr_reg_index), 
		.wr_reg_data(wr_reg_data)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		wr_en = 0;
		clk = 0;
		rd_reg_index_1 = 0;
		rd_reg_index_2 = 0;
		wr_reg_index = 0;
		wr_reg_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		//monitor signals
		$monitor ("Time : %g, rst = %b, wr_en = %b, rd_reg_index_1 = %d, \
rd_reg_index_2 = %d, wr_reg_index = %d, wr_reg_data = %d, reg_data_1 = %d, \
reg_data_2 = %d\n", $time, rst, wr_en, rd_reg_index_1, rd_reg_index_2,
		wr_reg_index, wr_reg_data, reg_data_1, reg_data_2);
		
		//reset the design
		rst = 1;
		#10;
		rst = 0;
		
		//read a couple of register
		$display("Reading a bunch of registers\n");
		rd_reg_index_1 = 10;
		rd_reg_index_2 = 15;
		#30;
		
		//write a value to a register
		$display ("Writing value to register\n");
		wr_reg_index = 5;
		wr_reg_data = 1234;
		wr_en = 1;
		#5;
		wr_en = 0;
		#20;
		
		//read back the value that was written
		$display("Reading back the value of the register that was written to\n");
		rd_reg_index_1 = 5;
		#20;
		$display ("The value of reg_array[5] is %d\n", reg_data_1);
		
		//ensure that writing to register 0 does not cause any change to it
		wr_reg_index = 0;
		wr_reg_data = 2431;
		wr_en = 1;
		#5;
		wr_en = 0;
		#20;
		
		//read back the value that was written
		$display("Reading back the value of the register 0\n");
		rd_reg_index_1 = 0;
		#20;
		$display ("The value of reg_array[0] is %d\n", reg_data_1);
		
		#50 $finish;
		
	end
	
	always begin
		//generate clock signal
		#1 clk = ~clk;
    end
     
endmodule
