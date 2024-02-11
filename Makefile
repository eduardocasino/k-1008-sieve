# Edit according to your setup:
#
# START : Load and start address
# ZPINI : Where to place zero page variables
# VMORG : Base address of the Visable Memory Card
#
START = 0400
ZPINI = 00A0
VMORG = A000

TARGETS = primes.hex primes.pap

all: $(TARGETS)

primes.hex: primes.bin
	srec_cat $< -binary -offset 0x$(START) -o $@ -Intel -address_length=2

primes.pap: primes.bin
	srec_cat $< -binary -offset 0x$(START) -o $@ -MOS_Technologies

primes.bin: primes.o primes.cfg
	ld65 -C $(basename $<).cfg -o $@ -vm -m $(basename $<).map $<

primes.cfg: primes.cfg.in Makefile
	sed 's/%%START%%/$$$(START)/; s/%%ZPINI%%/$$$(ZPINI)/' $< > $@

clean:
	$(RM) *.o *.lst *.map *.bin *.cfg

distclean: clean
	$(RM) $(TARGETS)

.s.o: 
	ca65 -D VMORG='$$$(VMORG)' -g -l $(basename $<).lst $<