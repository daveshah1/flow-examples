PROJ=demo

all: ${PROJ}.bit

firmware.elf: sections.lds start.s firmware.c
	riscv32-unknown-elf-gcc -march=rv32imc -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf start.s firmware.c

firmware.bin: firmware.elf
	riscv32-unknown-elf-objcopy -O binary firmware.elf /dev/stdout > firmware.bin

firmware.hex: firmware.bin
	python3 makehex.py $^ 4096 > $@

attosoc.json: attosoc.v picorv32.v simpleuart.v
	yosys -qp "synth_ecp5 -json $@ -top attosoc" $^

demo.json: demo.v pll.v firmware.hex attosoc_pnr.json
	yosys -ql yosys.log -p "synth_ecp5 -json $@ -top demo_top" $(filter %.v %.sv %.il %.json, $^)

%_pnr.json: %.json
	nextpnr-ecp5 --json $< --write $@ --um5g-45k --out-of-context

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --um5g-45k --lpf versa.lpf

%.bit: %_out.config
	ecppack --svf ${PROJ}.svf $< $@

${PROJ}.svf : ${PROJ}.bit

prog: ${PROJ}.svf
	openocd -f ecp5-versa5g.cfg -c "transport select jtag; init; svf $<; exit"

clean:
	rm -f *.svf *.bit *.config *.json

.PHONY: prog clean
