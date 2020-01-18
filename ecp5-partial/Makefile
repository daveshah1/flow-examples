PROJ=demo
CONSTR=versa.lpf

all: ${PROJ}.bit

${PROJ}.json: ${PROJ}.v
	yosys -p "synth_ecp5 -json $@" $<

${PROJ}_out.config: ${PROJ}.json
	nextpnr-ecp5 --json $< --lpf ${CONSTR} --write ${PROJ}_pnr.json --textcfg $@ --um5g-45k --package CABGA381

${PROJ}.bit: ${PROJ}_out.config
	ecppack --background --svf ${PROJ}.svf  $< $@

${PROJ}.svf: ${PROJ}.bit

prog: ${PROJ}.svf
	openocd -f ecp5-versa5g.cfg -c "transport select jtag; init; svf $<; exit"

${PROJ}_1_out.config: ${PROJ}_out.config make_connection.py
	nextpnr-ecp5 --json ${PROJ}_pnr.json --no-place --lpf ${CONSTR} --textcfg $@ --pre-pack make_connection.py --um5g-45k --package CABGA381


${PROJ}_delta.bit: ${PROJ}_out.config ${PROJ}_1_out.config
	ecppack --svf ${PROJ}_delta.svf --delta ${PROJ}_out.config ${PROJ}_1_out.config $@
	ecppack --svf ${PROJ}_unload.svf --delta ${PROJ}_1_out.config ${PROJ}_out.config ${PROJ}_unload.bit

${PROJ}_delta.svf: ${PROJ}_delta.bit

prog_delta: ${PROJ}_delta.svf
	openocd -f ecp5-versa5g.cfg -c "transport select jtag; init; svf $<; exit"

prog_unload:
	openocd -f ecp5-versa5g.cfg -c "transport select jtag; init; svf ${PROJ}_unload.svf; exit"





.PHONY: prog prog_delta prog_unload
.PRECIOUS: ${PROJ}.json ${PROJ}_out.config
