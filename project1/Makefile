# ECE437 Makefile

.SUFFIXES: .vhd 
COMPILE.VHDL = vcom
COMPILE.VHDLFLAGS = -93
SRCDIR = ./source
WORKDIR = ./work
VPATH= $(WORKDIR)

#Rules

%.vhd : $(SRCDIR)/%.vhd
	if [ ! -d $(WORKDIR) ]; then vlib $(WORKDIR); vmap lpm $(WORKDIR); fi
	$(COMPILE.VHDL) $(COMPILE.VHDLFLAGS) $(SRCDIR)/$@

# begin VHDL files (keep this)

registerFile_tb.vhd : registerFile.vhd
regTest.vhd: registerFile.vhd

# end VHDL files (keep this)

# Cache rules (cache labs)
# replace this ramAxB.vhd with your own
ram16x50.vhd : 220model.vhd
220pack.vhd:
	if [ ! -d $(WORKDIR) ]; then vlib $(WORKDIR); vmap lpm $(WORKDIR); fi
	$(COMPILE.VHDL) -87 ${HOME437}/lib/LPM/220pack.vhd
220model.vhd: 220pack.vhd
	if [ ! -d $(WORKDIR) ]; then vlib $(WORKDIR); vmap lpm $(WORKDIR); fi
	$(COMPILE.VHDL) -87 ${HOME437}/lib/LPM/220model.vhd

# Lab Rules DO NOT CHANGE THESE
# OR YOU MAY FAIL THE GRADING SCRIPT
lab1: registerFile_tb.vhd
lab2: tb_alu.vhd
lab4: tb_cpu.vhd
lab5: tb_cpu.vhd
lab6: tb_cpu.vhd
lab7: tb_cpu.vhd
lab8: tb_cpu.vhd
lab9: tb_cpu.vhd
lab10: tb_cpu.vhd
lab11: tb_cpu.vhd
lab12: tb_cpu.vhd


# Time Saving Rules
clean:
	$(RM) -rf $(WORKDIR) *.log transcript \._* mapped/*.vhd *.hex
