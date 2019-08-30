module top(input clk, input rstn, output [7:0] led, output [13:0] disp, input [7:0] dip);
	(* keep *) TRELLIS_SLICE #(.LUT0_INITVAL(16'hFFFF)) slice_i (.A0(), .F0(led[0]));

	reg [29:0] ctr;
	always @(posedge clk)
		ctr <= ctr + 1'b1;
	assign led[7:1] = ~ctr[29:23];
endmodule

