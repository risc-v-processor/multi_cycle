//sign and zero extend

//macros
//instruction width
`define BUS_WIDTH 32
//immediate input width
`define IMMEDIATE_WIDTH 20

//sign or zero extend mode
//12 bits to 32 bits (sign or zero extend)
`define STANDARD 2'b00
//immediate(12 bits) is a multiple of 2 bytes (BRANCH)
`define BRANCH 2'b01
//immediate constitutes the MSB bits of an operand (U_TYPE)
`define U_TYPE 2'b10
//immediate(20 bits) is a multiple of 2 bytes (JAL)
`define JAL 2'b11

module sz_ex(
	//sign or zero extended value
	output reg [(`BUS_WIDTH - 1):0] sz_ex_out,
	//sign or zero extend select
	input sz_ex_sel,
	//sign or zero extend mode
	input [1:0] sz_ex_mode,
	//immediate value
	input [(`IMMEDIATE_WIDTH -1):0] imm
);

	//combinational logic
	always @(*) begin
		//check the mode
		case (sz_ex_mode)
			//STANDARD
			`STANDARD: begin
				//copy the immediate value
				sz_ex_out[11:0] = imm[11:0];
				//perform sign or zero extend
				if (sz_ex_sel == 1'b1) begin
					//sign extend
					sz_ex_out[31:12] = {(`BUS_WIDTH-12){imm[11]}};
				end
				
				else begin
					//zero extend
					sz_ex_out[31:12] = {(`BUS_WIDTH-12){1'b0}};
				end
			end
			
			//BRANCH
			`BRANCH: begin
				//set LSb to zero
				sz_ex_out[0] = 1'b0;
				//copy the immediate value
				sz_ex_out[12:1] = imm[11:0]; 
				//perform sign or zero extend
				if (sz_ex_sel == 1'b1) begin
					//sign extend
					sz_ex_out[31:13] = {(`BUS_WIDTH-13){imm[11]}};
				end
				
				else begin
					//zero extend
					sz_ex_out[31:13] = {(`BUS_WIDTH-13){1'b0}};
				end
			end
			
			//U_TYPE
			`U_TYPE: begin
				//copy the immediate to MSb bits of output
				sz_ex_out[31:12] = imm[(`IMMEDIATE_WIDTH-1):0];
				//zero out the lower order bits
				sz_ex_out[11:0] = {(`BUS_WIDTH-20){1'b0}};
			end
			
			//JAL
			`JAL: begin
				//set LSb to zero
				sz_ex_out[0] = 1'b0;
				sz_ex_out[20:1] = imm[(`IMMEDIATE_WIDTH-1):0];
				//sign extend
				sz_ex_out[31:21] = {(`BUS_WIDTH-21){imm[19]}};
			end
			
			//default
			default: begin
				//set output to defult value to x (unknown)
				sz_ex_out = {`BUS_WIDTH{1'bx}};
			end
			
		endcase
		
	end
					
endmodule
