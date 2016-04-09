//multi cycle processor

//macros
//bus width
`define BUS_WIDTH 32

module multi_cycle_processor(
	//outputs
	//memory mapped I/O
	output [(`BUS_WIDTH-1):0] mem_map_io,
	//inputs
	//reset
	input rst,
	//clock
	input clk
);

	//pc block
	reg [(`BUS_WIDTH-1):0] alu_demux_0;
	wire [(`BUS_WIDTH-1):0] curr_addr;
	wire pc_update;
	
	pc_block pc_block_inst(
		.curr_addr(curr_addr),
		.next_addr(alu_demux_0),
		.pc_update(pc_update),
		.rst(rst),
		.clk(clk)
	);
	
	//memory select mux
	reg [(`BUS_WIDTH-1):0] alu_demux_2;
	reg [(`BUS_WIDTH-1):0] address;
	wire mem_sel;
	
	always @ (*) begin
		case (mem_sel)
			1'b0: begin
				//instruction memory
				address = curr_addr;
			end
			
			1'b1: begin
				//data memory
				address = alu_demux_2;
			end
		endcase
	end
	
	//memory 
	wire mem_wr_en;
	wire mem_sz_ex_sel;
	wire [1:0] mem_size;
	wire [(`BUS_WIDTH-1):0] reg_data_2;
	wire [(`BUS_WIDTH-1):0] out_val;
	
	memory memory_inst(
		.out_val(out_val),
		.wr_en(mem_wr_en),
		.mem_sz_ex_sel(mem_sz_ex_sel),
		.address(curr_addr),
		.in_val(reg_data_2),
		.mem_size(mem_size),
		.rst(rst),
		.clk(clk)
	);
	
	//instruction register
	wire [4:0] reg1;
	wire [4:0] reg2;
	wire [4:0] dest;
	wire [(`BUS_WIDTH-1):0] inst_out;
	wire load_ir;
	
	ir ir_inst(
		.reg1(reg1),
		.reg2(reg2),
		.dest(dest),
		.inst_out(inst_out),
		.load_ir(load_ir),
		.inst_in(out_val),
		.rst(rst),
		.clk(clk)
	);
	
	//data register
	wire [(`BUS_WIDTH-1):0] data_out;
	wire load_mdr;
	
	mdr mdr_inst(
		.data_out(data_out),
		.load_mdr(load_mdr),
		.data_in(out_val),
		.rst(rst),
		.clk(clk)
	);
	
	//register write back data mux
	reg [(`BUS_WIDTH-1):0] wr_reg_data;
	reg [(`BUS_WIDTH-1):0] alu_demux_1;
	wire wr_reg_mux_sel;
	
	always @ (*) begin
		case (mem_sel)
			1'b0: begin
				//value generated by ALU
				wr_reg_data = alu_demux_1;
			end
			
			1'b1: begin
				//value read from data memory
				wr_reg_data = data_out;
			end
		endcase
	end
	
	//register file
	wire [(`BUS_WIDTH-1):0] reg_data_1;
	wire reg_file_wr_en;
	
	reg_file reg_file_inst(
		.reg_data_1(reg_data_1),
		.reg_data_2(reg_data_2),
		.rd_reg_index_1(reg1),
		.rd_reg_index_2(reg2),
		.wr_reg_index(dest),
		.wr_en(reg_file_wr_en),
		.wr_reg_data(wr_reg_data),
		.rst(rst),
		.clk(clk)
	);
	
	//mux for selection of first operand to the ALU
	wire op1_sel;
	reg [(`BUS_WIDTH-1):0] Operand1;
	
	always @ (*) begin
		case (op1_sel)
			1'b0: begin
				//current PC value
				Operand1 = curr_addr;
			end
			
			1'b1: begin
				//value read from register file
				Operand1 = reg_data_1;
			end
		endcase
	end	
	
	//mux for selection of second operand to the ALU
	wire [1:0] op2_sel;
	reg [(`BUS_WIDTH-1):0] pc_increment_val;
	reg [(`BUS_WIDTH-1):0] Operand2;
	wire [(`BUS_WIDTH-1):0] sz_ex_out;
	
	always @ (*) begin
		case (op2_sel)
			2'b00: begin
				//pc_increment_value
				Operand2 = pc_increment_val;
			end
			
			2'b01: begin
				//value read from register file
				Operand2 = reg_data_2;
			end
			
			2'b10: begin
				//value got from sign and zero extend unit
				Operand2 = sz_ex_out;
			end
		endcase
	end	
	
	//ALU
	wire [4:0] alu_ctrl;
	wire bcond;
	wire [(`BUS_WIDTH-1):0] Out;
	
	Exec Exec_inst(
		.Operation(alu_ctrl),
		.Operand1(Operand1),
		.Operand2(Operand2),
		.bcond(bcond),
		.Out(Out)
	);
	
	//ALU output demux
	wire [1:0] alu_demux;

	always @ (*) begin
		case (alu_demux)
			2'b00: begin
				//connect to PC block
				alu_demux_0 = Out;
			end
			
			2'b01: begin
				//connect to register file
				alu_demux_1 = Out;
			end
			
			2'b10: begin
				//connect to memory
				alu_demux_2 = Out;
			end
		endcase
	end		
	
	//sign and zero extend unit
	wire sz_ex_sel;
	wire [(`BUS_WIDTH-1):0] imm;
	wire [1:0] sz_ex_mode;
	
	sz_ex sz_ex_inst(
		.sz_ex_sel(sz_ex_sel),
		.imm(imm),
		.sz_ex_mode(sz_ex_mode),
		.sz_ex_out(sz_ex_out)
	);
	
	//control unit
	cntl_mc cntl_mc_inst(
		.pc_update(pc_update),
		.load_ir(load_ir),
		.load_mdr(load_mdr),
		.imm(imm),
		.mem_sel(mem_sel),
		.mem_size(mem_size),
		.mem_sz_ex_sel(mem_sz_ex_sel),
		.sz_ex_sel(sz_ex_sel),
		.sz_ex_mode(sz_ex_mode),
		.mem_wr_en(mem_wr_en),
		.reg_file_wr_en(reg_file_wr_en),
		.wr_reg_mux_sel(wr_reg_mux_sel),
		.inst(inst_out),
		.alu_demux(alu_demux),
		.alu_ctrl(alu_ctrl),
		.bcond(bcond),
		.op1_sel(op1_sel),
		.op2_sel(op2_sel)
	);
	
endmodule