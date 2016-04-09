//Register File

//macros
//Register file properties
`define BUS_WIDTH 32

module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
    );

	wire rst = ~rst_n; // make reset active high
	
	// these signals should be high-z when not used
	assign spi_miso = 1'bz;
	assign avr_rx = 1'bz;
	assign spi_channel = 4'bzzzz;
	
	wire [(`BUS_WIDTH-1):0] mem_map_io;
	
	assign led = mem_map_io[7:0];
	
	wire clk_d;
	//instance of clock generation unit
	clock_gen clk_gen_inst( 
		.clk_d(clk_d),
		.rst(rst),
		.clk(clk) 
	);
												
	//instance of multi cycle processor
	multi_cycle_processor proc(
		.mem_map_io(mem_map_io),
		.rst(rst),
		.clk(clk_d)
	);
		
endmodule
