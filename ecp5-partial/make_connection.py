ctx.makeConnection("ctr[26]", "slice_i", "A0")
ctx.cells["slice_i"].setParam("LUT0_INITVAL", "0101010101010101") # LED is active low so invert
ctx.cells["slice_i"].setParam("A0MUX", "A0") # remove constant mux on LUT input
