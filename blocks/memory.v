`timescale 1ns / 1ps

`define MEM_VECTOR_SIZE 64
`define I_MEM_SIZE 32
`define WORD 2'b10
`define MEM_MAP_IO_ADDRESS 128
`define BUS_WIDTH 32

module memory(
    input clk,
    input rst,
	 input wr_en,
    input [(`BUS_WIDTH-1):0] address,
	 input [(`BUS_WIDTH-1):0] in_data,
	 input [1:0] mem_size,
	 input sz_ex,
	 output reg [(`BUS_WIDTH-1):0] mem_map_io,
    output reg [(`BUS_WIDTH-1):0] out_data
    );

reg [1:0] m_size ;
reg m_sz_ex ;
reg mem_map_io_wr_en ,m_wr_en ;
// reg [31:0] m_out_data ,m_mem_map_io ;
mem MEM (
      .clk(clk),
		.rst(rst),
		.data_out(out_data),
		.mem_size(m_size),
		.sz_ex(m_sz_ex),
		.wr_en(m_wr_en),
		.address(address),
		.data_in(in_data)
		);
		
always@(posedge clk)
  begin
    if( address < `MEM_VECTOR_SIZE ) begin
	   if( address < `I_MEM_SIZE ) begin 
		    m_size <= `WORD ;
		    m_sz_ex <= 1'bx ;
		end
		
		else if(address > `I_MEM_SIZE && address != `MEM_MAP_IO_ADDRESS) begin 
		     m_size <= mem_size ;
           m_sz_ex <= sz_ex ;
            end     
	     end
   end
 always @(posedge clk) begin 
	    if(address == `MEM_MAP_IO_ADDRESS ) begin 
		      if(wr_en == 1'b1 ) begin
				    mem_map_io_wr_en = 1'b1 ;
					  m_wr_en = 1'b0 ;
					 end
				else if(wr_en == 1'b0) begin
				    mem_map_io_wr_en = 1'b0 ;
					  m_wr_en = 1'b0 ;
				    out_data <= mem_map_io ;
				end
			end
	end

always@(posedge clk) begin 
  if( rst == 1'b1 ) begin 
     mem_map_io <= 32'b0 ;
     end
	else if(mem_map_io_wr_en == 1'b1 ) begin
	      mem_map_io <= in_data ;
     	 end
  end	 
 
 
endmodule
