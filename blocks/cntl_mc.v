`timescale 1ns / 1ps

`define ALU_CTRL_WIDTH 5
`define INSTRUCTION_WIDTH 32

//operand width
`define OPERAND_WIDTH 32
`define IMM_WIDTH 21

`define SIGN_EXTEND 1'b1
`define ZERO_EXTEND 1'b0


//Define the states
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
//U-TYPE
`define LUI 5'b01101
`define AUIPC 5'b00101
`define JAL 5'b11011
`define JALR 5'b11001
`define BRANCH 5'b11000
`define LOAD 5'b00000
`define STORE 5'b01000
`define I_TYPE 5'b00100
`define R_TYPE 5'b01100


module cntl_mc(
		input [(`INSTRUCTION_WIDTH-1):0] instruction,
		input bcond,
		input clk,
		input rst,
		output reg [11:0] micro,
		output reg sz_ex,
		output reg [(`OPERAND_WIDTH-1):0] immediate,
		output reg mem_sel,
		output reg pc_update,
		output reg load_ir,
		output reg load_mdr,
		output reg mem_wr_en,
		output reg reg_file_wr_en,
		output reg wr_reg_mux_sel,
		output reg op1_sel,
		output reg [1:0] op2_sel,
		output reg [1:0] alu_demux,
		output reg [(`ALU_CTRL_WIDTH-1):0] alu_ctrl,
		output reg [1:0] memory_size,
		output reg [4:0] curr_state
    );
	 
	 reg [11:0] micro_inst [0:23];
	 reg [11:0] cntl_sig;
	 reg [4:0] state;
	 reg [4:0] next_state;
	
		
	initial
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
	
//Assign the states and load the microinstructions for the state	
always@(posedge clk)
	begin
		if(rst)
			begin
				state=`FETCH;
				{pc_update,load_ir,load_mdr,mem_sel,mem_wr_en,reg_file_wr_en,wr_reg_mux_sel,op1_sel,op2_sel,
					alu_demux} <= micro_inst[`FETCH];
					micro<=micro_inst[`FETCH];
			end
		
		else
			begin
				state=next_state;
				{pc_update,load_ir,load_mdr,mem_sel,mem_wr_en,reg_file_wr_en,wr_reg_mux_sel,op1_sel,op2_sel,
					alu_demux} <= cntl_sig;
					micro<=cntl_sig;
			end
			curr_state=state;
	end
	
	
//Define the state transitions and the ALU and memory control signals for each of the states
	always @(state or bcond)		
		begin
			case(state)			
			`FETCH:begin
			  next_state=`LOAD_IR;
			  alu_ctrl=5'bxxxxx;
			end
			
			`LOAD_IR:begin
			  next_state=`DECODE;
			  alu_ctrl=5'bxxxxx;
			end
			
			`DECODE:begin
	//In the decode state determine the immediate values, sign-zero signal,
  //ALU control signal and the memory addressing mode
			     case(instruction[6:2])
			       `BRANCH:begin
			          next_state=`BRANCH_S;
						 
						
						  immediate[0] = 1'b0;
						  immediate[12:1] = {instruction[7], instruction[30:25], instruction[11:8]};
						  immediate[(`IMM_WIDTH-1):13]=1'bx;
						  
						 if(instruction[14:13] == 2'b11)
							sz_ex=0;					
						  //else perform sign extend
						 else begin
							sz_ex=1;						  
					  end
						
						//ALU control signal
					//set the alu_ctrl signal to {1'b1, 1'b0, "funct3"}
					//bit3 = 1'b0, no subtract instructions (I-type)
					//MSB (bit 4) = 1'b1, branch
					alu_ctrl = {1'b1, 1'b0, instruction[14:12]};					
					//data memory size
					//data is not written to data memory
					memory_size = 2'bxx;	
			        end									  
				
						`JALR:begin
							  next_state=`JALR_S;	
							  immediate[11:0] = instruction[31:20];
							  immediate[(`IMM_WIDTH-1):12]=1'bx;
							  alu_ctrl = instruction[6:2];					
							  memory_size = 2'bxx;
							  sz_ex=1;
						 end
						
						`JAL:begin
							next_state=`JAL_S;	
							immediate[0] = 1'b0;
							immediate[20:1] = {instruction[19:12], instruction[20], instruction[30:21]};
							alu_ctrl = {(`ALU_CTRL_WIDTH){1'bx}};					
							memory_size = 2'bxx;	
							sz_ex=1;	
						end
						
						`AUIPC:begin
							next_state=`AUIPC_S;
							immediate[19:0] = instruction[31:12];
						   immediate[(`IMM_WIDTH-1)]=1'bx;
							alu_ctrl = {(`ALU_CTRL_WIDTH){1'bx}};
							memory_size = 2'bxx;	
							sz_ex=0;
						end
						
						`LUI:begin
							next_state=`LUI_S;
							immediate[19:0] = instruction[31:12];
							immediate[(`IMM_WIDTH-1)]=1'bx;
							alu_ctrl = 5'b11000;
						   memory_size = 2'bxx;	
							sz_ex=1;
						end
						
						`STORE:begin
						  next_state=`STORE_S;
						  immediate[11:0] = {instruction[31:25],instruction[11:7]};
						  immediate[(`IMM_WIDTH-1):12]=1'bx;
						  alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
						  memory_size = instruction[13:12];
						  sz_ex=1;
						end
						
						`LOAD:begin
						  next_state=`LOAD_S;
						  immediate = instruction[31:20];
						  alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
						  sz_ex=1;
					
						//data memory size
						//size depends on the instruction
						memory_size = instruction[13:12];
							end
												
					  `I_TYPE:begin
						  next_state=`I_TYPE_S;						
					     immediate[11:0] = instruction[31:20];
						  immediate[(`IMM_WIDTH-1):12]=1'bx;
							//perform zero extension only for SLTIU
							if(instruction[14:12] == 3'b011) begin
									sz_ex=0;
							end								
								//else perform sign extend
							else begin
									sz_ex=1;
							end
								
								
							if(instruction[14:12] == 3'b010 || instruction[14:12] == 3'b011) begin
							//Instructions that involve subtract operation (SLTI and SLTIU respectively)
							//ALU control signal
							//set LSB 3 bits to the "funct3" field
							//bit 3 = 1'b1 to indicate stubract operation
							//bit 4 = 0 (no branching)
							alu_ctrl = {1'b0, 1'b1, instruction[14:12]};
						end
						
						else begin
							//Other ALU instruction
							//ALU control signal
							//set the alu_ctrl signal to {2'b00, "funct3"}
							//bit3 = 1'b0, no subtract operation
							//MSB (bit 4) = 1'b0, no branching
							alu_ctrl = {2'b00, instruction[14:12]};
						end		
						
						memory_size = 2'bxx;	
						end
						
						`R_TYPE:begin
						  next_state=`R_TYPE_S;
						  immediate={(`OPERAND_WIDTH-1){1'bx}};
						  alu_ctrl = {1'b0,instruction[30], instruction[14:12]};
						  memory_size = 2'bxx;	
						  sz_ex=1'bx;
						end	
					endcase					
			 end
			
			//End of decode state
			
			`BRANCH_S:begin
			  if(bcond==0)
			   next_state=`PC_WR;
			  else
			   next_state=`BCOND1;	
					
				alu_ctrl=5'bxxxxx;
			 end
			
			`PC_WR:begin
				next_state=`FETCH;
				alu_ctrl=5'b00000;
				alu_ctrl=5'bxxxxx;
			end
			 
			`BCOND1:begin
			   next_state=`PC_WR;
				alu_ctrl=5'bxxxxx;
			end
			
			`JALR_S:begin
			   next_state=`JALR2;
				alu_ctrl=5'bxxxxx;
			end
			
			`JALR2:begin
			  next_state=`JALR_ADD;
			  alu_ctrl=5'bxxxxx;
			end
			
			`JALR_ADD:begin	
				next_state=`PC_WR;
				alu_ctrl=5'b00000;				
			end
			
			`JAL_S:begin
			  next_state=`JAL2;
			  alu_ctrl=5'bxxxxx;
			end
			
			`JAL2:begin
			  next_state=`ALU2PC;	
			  alu_ctrl=5'bxxxxx;
			end
			
			`ALU2PC:begin
			   next_state=`PC_WR;
				alu_ctrl=5'b00000;
			end
			
			`AUIPC_S:begin
			   next_state=`WRITE_BACK;
				alu_ctrl=5'bxxxxx;
			end
			
			`WRITE_BACK:begin
			   next_state=`PC_ADD;
				alu_ctrl=5'bxxxxx;
			end
			
			`PC_ADD:begin
				next_state=`PC_WR;
				alu_ctrl=5'b00000;
			end
			
			`LUI_S:begin
			   next_state=`WRITE_BACK;
				alu_ctrl=5'bxxxxx;
			end
			
			`STORE_S:begin
			  next_state=`STORE_MEM;
			  alu_ctrl=5'bxxxxx;
			end
			
			`STORE_MEM:begin
			   next_state=`PC_ADD;
				alu_ctrl=5'bxxxxx;
			end
			
			`LOAD_S:begin
			   next_state=`LOAD2;
				alu_ctrl=5'bxxxxx;
			end
			
			`LOAD2:begin
			  next_state=`LOAD_MDR;
			  alu_ctrl=5'bxxxxx;
			end
			
			`LOAD_MDR:begin
				next_state=`LOAD_WR;
				alu_ctrl=5'bxxxxx;
			end
			
			`LOAD_WR:begin
				next_state=`PC_ADD;
				alu_ctrl=5'bxxxxx;
			end
    			
    		`I_TYPE_S:begin
			   next_state=`WRITE_BACK;
				alu_ctrl=5'bxxxxx;
			end
			
			`R_TYPE_S:begin
			   next_state=`WRITE_BACK;
				alu_ctrl=5'bxxxxx;
			end
			
			default:begin
			  next_state=`FETCH;
			  alu_ctrl=5'bxxxxx;
			end
			endcase
			
		  cntl_sig=micro_inst[next_state];
			
		end
	
endmodule		
