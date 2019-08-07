`default_nettype none

module demo_top(
	input clkin,
	input uart_rx,
	output uart_tx,
	output [7:0] led,
	output [13:0] disp
);

	wire clk_48;
	wire locked;

	pll pll_i (
		.clkin(clkin),
		.clkout0(clk_48),
		.locked(locked)
	);

	reg [31:0] soc_led = 32'b0;
	reg [31:0] soc_14seg = 32'b0;


	wire [15:0] fw_addr;
	wire fw_valid;
	reg [31:0] fw_rdata;
	reg fw_ready;

	localparam FW_SIZE = 4096;
	reg [31:0] fw_rom [0:FW_SIZE-1];
	initial $readmemh("firmware.hex", fw_rom);

	always @(posedge clk_48) begin
		fw_ready <= 1'b0;
		if (fw_valid && !fw_ready) begin
			fw_ready <= 1'b1;
			fw_rdata <= fw_rom[fw_addr];
		end
	end

 	wire [31:0] iomem_addr, iomem_wdata;
	wire [3:0] iomem_wstrb;
	wire iomem_valid;
	reg [31:0] iomem_rdata = 32'b0;
	reg iomem_ready = 1'b0;

	always @(posedge clk_48) begin
		iomem_ready <= 1'b0;
		if (iomem_valid && !iomem_ready) begin
			casez (iomem_addr[9:2])
				8'h00: begin
					iomem_rdata <= soc_led;
					if (iomem_wstrb[0]) soc_led[7:0] <= iomem_wdata[7:0];
					if (iomem_wstrb[1]) soc_led[15:8] <= iomem_wdata[15:8];
					if (iomem_wstrb[2]) soc_led[23:16] <= iomem_wdata[23:16];
					if (iomem_wstrb[3]) soc_led[31:24] <= iomem_wdata[31:24];
				end
				8'h01: begin
					iomem_rdata <= soc_14seg;
					if (iomem_wstrb[0]) soc_14seg[7:0] <= iomem_wdata[7:0];
					if (iomem_wstrb[1]) soc_14seg[15:8] <= iomem_wdata[15:8];
					if (iomem_wstrb[2]) soc_14seg[23:16] <= iomem_wdata[23:16];
					if (iomem_wstrb[3]) soc_14seg[31:24] <= iomem_wdata[31:24];
				end

				default:
					iomem_rdata <= {24'hC0FFEE, iomem_addr[9:2]};
			endcase
			iomem_ready <= 1'b1;
		end
	end

	attosoc soc_i(
		.clk(clk_48),
		.reset(!locked),

		.fw_addr(fw_addr),
		.fw_rdata(fw_rdata),
		.fw_valid(fw_valid),
		.fw_ready(fw_ready),

		.iomem_addr(iomem_addr),
		.iomem_rdata(iomem_rdata),
		.iomem_wdata(iomem_wdata),
		.iomem_wstrb(iomem_wstrb),
		.iomem_valid(iomem_valid),
		.iomem_ready(iomem_ready),

		.uart_tx(uart_tx),
		.uart_rx(uart_rx)
	);

	assign led = ~soc_led[7:0];
	assign disp = ~soc_14seg[13:0];
endmodule
