//Control unit

//macros
//alu control signal width
`define ALU_CTRL_WIDTH 5
//instruction width
`define INSTRUCTION_WIDTH 32

//operand width
`define OPERAND_WIDTH 32
//immediate width
`define IMM_WIDTH 20

//zero extend
`define ZERO_EXTEND 1'b0
//sign extend
`define SIGN_EXTEND 1'b1

//sign or zero extend mode
//12 bits to 32 bits (sign or zero extend)
`define SZ_EX_STANDARD 2'b00
//immediate(12 bits) is a multiple of 2 bytes (BRANCH)
`define SZ_EX_BRANCH 2'b01
//immediate constitutes the MSB bits of an operand (U_TYPE)
`define SZ_EX_U_TYPE 2'b10
//immediate(20 bits) is a multiple of 2 bytes (JAL)
`define SZ_EX_JAL 2'b11

//memory size
//word (32 bits)
`define WORD 2'b10
//half word (16 bits)
`define HALF_WORD 2'b01
//byte (8 bits)
`define BYTE 2'b00

//Define the states of the FSM
//s0 through s23
`define FETCH 0
`define LOAD_IR 1
`define DECODE 2
`define BRANCH_S 3
`define BCOND1 4
`define JALR_S 5
`define JALR2 6
`define JAL_S 7
`define JAL2 8
`define ALU2PC 9
`define AUIPC_S 10
`define WRITE_BACK 11
`define LUI_S 12
`define STORE_S 13
`define STORE_MEM 14
`define LOAD_S 15
`define LOAD2 16
`define I_TYPE_S 17
`define R_TYPE_S 18
`define JALR_ADD 19
`define LOAD_MDR 20
`define LOAD_WR 21
`define PC_ADD 22
`define PC_WR 23

//Define the opcodes for each instruction type
//U-type
`define LUI 5'b01101
`define AUIPC 5'b00101
//UJ_type
`define JAL 5'b11011
//I-type
`define I_TYPE 5'b00100
`define JALR 5'b11001
`define LOAD 5'b00000
//SB-type
`define BRANCH 5'b11000
//S-type
`define STORE 5'b01000
//R-type
`define R_TYPE 5'b01100


module cntl_tst(
	//inputs
	input [(`INSTRUCTION_WIDTH-1):0] inst,
	input bcond,
	input clk,
	input rst,
	//outputs
	output reg sz_ex_sel,
	output reg [1:0] sz_ex_mode,
	output reg mem_sz_ex_sel,
	output reg [(`IMM_WIDTH-1):0] imm,
	output reg mem_sel,
	output reg [1:0] mem_size,
	output reg pc_update,
	output reg load_ir,
	output reg load_mdr,
	output reg mem_wr_en,
	output reg reg_file_wr_en,
	output reg wr_reg_mux_sel,
	output reg op1_sel,
	output reg [1:0] op2_sel,
	output reg [1:0] alu_demux,
	output reg [(`ALU_CTRL_WIDTH-1):0] alu_ctrl
);
	 
	reg [11:0] micro_inst [0:23];
	reg [11:0] cntl_sig;
	reg [4:0] state;
	reg [4:0] next_state;
	
	always@(rst)
	begin
		micro_inst[`FETCH]=12'b000000xxxxxx;
			micro_inst[`LOAD_IR]=12'b010x00xxxxxx;
			micro_inst[`DECODE]=12'b000x00xxxxxx;
			micro_inst[`BRANCH_S]=12'b000x00x101xx;
			micro_inst[`BCOND1]=12'b000x00x010xx;
			micro_inst[`JALR_S]=12'b000x00x000xx;
			micro_inst[`JALR2]=12'b000x01xxxx01;
			micro_inst[`JAL_S]=12'b000x00x000xx;
			micro_inst[`JAL2]=12'b000x01xxxx01;
			micro_inst[`ALU2PC]=12'b000x00x010xx;
			micro_inst[`AUIPC]=12'b000x00x010xx;
			micro_inst[`WRITE_BACK]=12'b000x010xxx01;
			micro_inst[`LUI_S]=12'b000x00xx10xx;
			micro_inst[`STORE_S]=12'b000x00x110xx;
			micro_inst[`STORE_MEM]=12'b000110xxxx10;
			micro_inst[`LOAD_S]=12'b000x00x110xx;
			micro_inst[`LOAD2]=12'b000100xxxx01;
			micro_inst[`I_TYPE_S]=12'b000x00x110xx;
			micro_inst[`R_TYPE_S]=12'b000x00x101xx;
			micro_inst[`JALR_ADD]=12'b000x00x110xx;
			micro_inst[`LOAD_MDR]=12'b001x00xxxxxx;
			micro_inst[`LOAD_WR]=12'b000x011000xx;
			micro_inst[`PC_ADD]=12'b000x00xxxx00;
			micro_inst[`PC_WR]=12'b100x00xxxxxx;
	end
	
/*	initial
		begin
			micro_inst[`FETCH]=12'b000000xxxxxx;
			micro_inst[`LOAD_IR]=12'b010x00xxxxxx;
			micro_inst[`DECODE]=12'b000x00xxxxxx;
			micro_inst[`BRANCH_S]=12'b000x00x101xx;
			micro_inst[`BCOND1]=12'b000x00x010xx;
			micro_inst[`JALR_S]=12'b000x00x000xx;
			micro_inst[`JALR2]=12'b000x01xxxx01;
			micro_inst[`JAL_S]=12'b000x00x000xx;
			micro_inst[`JAL2]=12'b000x01xxxx01;
			micro_inst[`ALU2PC]=12'b000x00x010xx;
			micro_inst[`AUIPC]=12'b000x00x010xx;
			micro_inst[`WRITE_BACK]=12'b000x010xxx01;
			micro_inst[`LUI_S]=12'b000x00xx10xx;
			micro_inst[`STORE_S]=12'b000x00x110xx;
			micro_inst[`STORE_MEM]=12'b000110xxxx10;
			micro_inst[`LOAD_S]=12'b000x00x110xx;
			micro_inst[`LOAD2]=12'b000100xxxx01;
			micro_inst[`I_TYPE_S]=12'b000x00x110xx;
			micro_inst[`R_TYPE_S]=12'b000x00x101xx;
			micro_inst[`JALR_ADD]=12'b000x00x110xx;
			micro_inst[`LOAD_MDR]=12'b001x00xxxxxx;
			micro_inst[`LOAD_WR]=12'b000x011000xx;
			micro_inst[`PC_ADD]=12'b000x00xxxx00;
			micro_inst[`PC_WR]=12'b100x00xxxxxx;
	end	*/	
	
	
	//Assign the states and load the micro-instructions for the state
	//sequential logic	
	always @ (posedge clk) begin
		//check reset signal
		if(rst == 1'b1) begin
			//Initialize the control store
			//control store specifies the value of each of those control signals 
			//that are set based on the state of the FSM
			
			
			//initial state
			state <= `FETCH;
			{pc_update, load_ir, load_mdr, mem_sel, mem_wr_en, reg_file_wr_en, wr_reg_mux_sel,
				op1_sel, op2_sel, alu_demux} <= 12'b000000xxxxxx; //micro-instruction for FETCH
		end
		
		//transition to next state and update the control signals from control store	
		else begin
			/*if ((next_state == `WRITE_BACK) || (next_state == `PC_WR)) begin
				//retain the choice of inputs to the ALU as is from previous state
				//since the value generated by the ALU will be writen back in the new state,
				//the choice of inputs to the ALU are to be maintained the same as in previous state
				{pc_update, load_ir, load_mdr, mem_sel, mem_wr_en, reg_file_wr_en,
					wr_reg_mux_sel, alu_demux} <= {cntl_sig[11:5], cntl_sig[1:0]};
			end
			
			else begin*/
				//update all the control signals based on the values in the control store
				{pc_update, load_ir, load_mdr, mem_sel, mem_wr_en, reg_file_wr_en, wr_reg_mux_sel,
					op1_sel, op2_sel, alu_demux} <= cntl_sig;
			//end
			
			state <= next_state;
		end

	end
	
	
	//Define the state transitions and the ALU and memory control signals for each of the states
	//Following are the control signals that depend on the instruction rather than the FSM state
	/*
	imm
	mem_size
	mem_sz_ex_sel
	sz_ex_sel
	sz_ex_mode
	alu_ctrl
	*/
	//combinational logic
	always @ (*) begin
		if(state==`FETCH)			
			begin
				next_state = `LOAD_IR;
				mem_size = `WORD;
				mem_sz_ex_sel = `ZERO_EXTEND;
				alu_ctrl=5'bxxxxx;
			end
			
			else if (state==`LOAD_IR)begin
				next_state=`DECODE;
				mem_size =2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if (state==`DECODE)begin
			//In the decode state determine the immediate values, sign-zero signal,
			//ALU control signal and the memory addressing mode
				if(inst[6:2]==`BRANCH)
					begin
						next_state=`BRANCH_S;
						imm[11:0] = {inst[31], inst[7], inst[30:25], inst[11:8]};
						imm[19:12]=8'bx;
						sz_ex_mode =`SZ_EX_BRANCH;
						  
						if(inst[14:13] == 2'b11) begin
							sz_ex_sel = `ZERO_EXTEND;					
						end
						
						//else perform sign extend
						else begin
							sz_ex_sel = `SIGN_EXTEND;						  
						end
						
						//ALU control signal
						//set the alu_ctrl signal to {1'b1, 1'b0, "funct3"}
						//bit3 = 1'b0, no subtract instructions (I-type)
						//MSB (bit 4) = 1'b1, branch
						alu_ctrl = {1'b1, 1'b0, inst[14:12]};
					end									  
				
					else if(inst[6:2]==`JALR)begin
						next_state = `JALR_S;	
						imm[11:0] = inst[31:20];
						imm[19:12]=8'bx;
						sz_ex_mode = `SZ_EX_STANDARD;
						sz_ex_sel = `SIGN_EXTEND;
						//set the alu control signal to ADD in order to compute return address
						alu_ctrl = 5'b00000;
					end
						
					else if(inst[6:2]==`JAL)begin
						next_state=`JAL_S;
						imm[19:0] = {inst[31], inst[19:12], inst[20], inst[30:21]};
						sz_ex_mode = `SZ_EX_JAL;
						sz_ex_sel = `SIGN_EXTEND;
						//set the alu control signal to ADD in order to compute return address
						alu_ctrl = 5'b00000;
					end
						
					else if(inst[6:2]==`AUIPC)begin
						next_state = `AUIPC_S;
						imm[19:0] = inst[31:12];
						sz_ex_mode = `SZ_EX_U_TYPE;
						sz_ex_sel = `ZERO_EXTEND;
					end
						
					else if(inst[6:2]==`LUI)begin
						next_state = `LUI_S;
						imm[19:0] = inst[31:12];
						sz_ex_mode = `SZ_EX_U_TYPE;
						sz_ex_sel = `SIGN_EXTEND;
						alu_ctrl = 5'b11000;							
					end
						
					else if(inst[6:2]==`STORE)begin
						next_state = `STORE_S;
						imm[11:0] = {inst[31:25],inst[11:7]};
						imm[19:12]=8'bx;
						sz_ex_mode = `SZ_EX_STANDARD;
						sz_ex_sel = `SIGN_EXTEND;
						//target address computation 
						alu_ctrl = 5'b00000;
						mem_size = inst[13:12];  
					end
						
					else if(inst[6:2]==`LOAD)begin
						next_state = `LOAD_S;
						imm[11:0] = inst[31:20];
						imm[19:12]=8'bx;
						sz_ex_mode = `SZ_EX_STANDARD;
						sz_ex_sel = `SIGN_EXTEND;
						alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};		
						if(inst[14]) begin
							mem_sz_ex_sel = `ZERO_EXTEND;
						end
						 
						else begin
							mem_sz_ex_sel = `SIGN_EXTEND;
						end
						//data memory size depends on the instruction
						mem_size = inst[13:12];
					end
												
					else if(inst[6:2]==`I_TYPE)begin
						next_state = `I_TYPE_S;
						//imm[11:0] = inst[31:20];
						imm={8'bx,inst[31:20]};
						//imm[19:12]=8'bx;
						sz_ex_mode = `SZ_EX_STANDARD;
						//perform zero extension only for SLTIU
						if(inst[14:12] == 3'b011) begin
								sz_ex_sel = `ZERO_EXTEND;
						end								
						
						//else perform sign extend
						else begin
								sz_ex_sel = `SIGN_EXTEND;
						end
							
						if((inst[14:12] == 3'b010) || (inst[14:12] == 3'b011)) begin
							//Instructions that involve subtract operation (SLTI and SLTIU respectively)
							//ALU control signal
							//set LSB 3 bits to the "funct3" field
							//bit 3 = 1'b1 to indicate stubract operation
							//bit 4 = 0 (no branching)
							alu_ctrl = {1'b0, 1'b1, inst[14:12]};
						end
						
						else begin
							//Other ALU instruction
							//ALU control signal
							//set the alu_ctrl signal to {2'b00, "funct3"}
							//bit3 = 1'b0, no subtract operation
							//MSB (bit 4) = 1'b0, no branching
							alu_ctrl = {2'b00, inst[14:12]};
						end		
						
					end
						
					else if(inst[6:2]==`R_TYPE)begin
						next_state=`R_TYPE_S;
						  mem_sz_ex_sel=1'bx;
						  sz_ex_mode=1'bx;
						  imm[19:0]={(`IMM_WIDTH-1){1'bx}};
						  alu_ctrl = {1'b0,inst[30], inst[14:12]};
						  mem_size = 2'bxx;	
						  sz_ex_sel=1'bx;
					end	
					
					else
						next_state=`FETCH;
						  mem_sz_ex_sel=1'bx;
						  sz_ex_mode=1'bx;
						  imm[19:0]={(`IMM_WIDTH-1){1'bx}};
						  alu_ctrl = 5'bx;
						  mem_size = 2'bxx;	
						  sz_ex_sel=1'bx;						
					
			end
			
			//End of decode state
			
			else if(state==`BRANCH_S)begin
				if(bcond == 1'b0) begin
					next_state = `PC_WR;
					mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
				end
				
				else begin
					next_state = `BCOND1;	
					mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
				end
			 end
			
			else if(state==`PC_WR)begin
				next_state = `FETCH;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			 
			else if(state==`BCOND1)begin
				next_state = `PC_WR;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`JALR_S)begin
				next_state = `JALR2;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`JALR2)begin
				next_state = `JALR_ADD;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`JALR_ADD)begin	
				next_state = `PC_WR;
				mem_size = `WORD;
				mem_sz_ex_sel = 1'bx;
				
				//ALU control signal for JALR (target address computation)
				alu_ctrl = inst[6:2];				
			end
			
			else if(state==`JAL_S)begin
				next_state = `JAL2;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`JAL2)begin
				next_state = `ALU2PC;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`ALU2PC)begin
				next_state = `PC_WR;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				
				//ALU control signal for JAL (target address computation)
				alu_ctrl = inst[6:2];
			end
			
			else if(state==`AUIPC_S)begin
				next_state = `WRITE_BACK;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`WRITE_BACK)begin
				next_state = `PC_ADD;
				mem_size = `WORD;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`PC_ADD)begin
				next_state = `PC_WR;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				
				//ALU control signal for ADD
				alu_ctrl = 5'b00000;
			end
			
			else if(state==`LUI_S)begin
				next_state = `WRITE_BACK;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`STORE_S)begin
				next_state = `STORE_MEM;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`STORE_MEM)begin
				next_state = `PC_ADD;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`LOAD_S)begin
				next_state = `LOAD2;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`LOAD2)begin
				next_state = `LOAD_MDR;
				mem_size = 2'bx;
				mem_sz_ex_sel = 1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`LOAD_MDR)begin
				next_state = `LOAD_WR;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`LOAD_WR)begin
				next_state = `PC_ADD;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
    			
			else if(state==`I_TYPE_S)begin
				next_state = `WRITE_BACK;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else if(state==`R_TYPE_S)begin
				next_state = `WRITE_BACK;
				mem_size =2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end
			
			else begin
				next_state = `FETCH;
				mem_size = 2'bx;
				mem_sz_ex_sel =1'bx;
				alu_ctrl=5'bxxxxx;
			end			
		cntl_sig = micro_inst[next_state];
			
	end
	
endmodule		
