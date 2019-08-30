# ECP5 partial bitstream flow

Run `make prog` to program the base bitstream

Run `make prog_delta` to program the delta bitstream that connected LED D25 to counter bit 26

Run `make prog_unload` to unload the delta bitstream by programming the reverse change

**Always run `make prog_unload` before programming a new delta bitstream (e.g. after
changing the counter bit in make_connection.py)**

You can also try connecting DIP switches (dip[0] to dip[7]) or the button (rstn) to the LED

Currently this needs the `partial` branch of trellis and `dave/ecp5-partial-demo-fixes` branch of nextpnr.