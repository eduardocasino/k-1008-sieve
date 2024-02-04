# Edit according to your setup:
#
# START : Load and start address
# VMORG : Base address of the Visable Memory Card
#
START = 0400
VMORG = A000

TARGETS = primes.hex primes.pap

all: $(TARGETS)

primes.hex: primes.bin
	srec_cat $< -binary -offset 0x$(START) -o $@ -Intel -address_length=2

primes.pap: primes.bin
	srec_cat $< -binary -offset 0x$(START) -o $@ -MOS_Technologies

primes.bin: primes.o primes.cfg
	ld65 -C $(basename $<).cfg -o $@ -vm -m $(basename $<).map $<

primes.cfg: primes.cfg.in
	sed 's/%%START%%/$$$(START)/' $< > $@

clean:
	$(RM) *.o *.lst *.map *.bin *.cfg

distclean: clean
	$(RM) $(TARGETS)

.s.o: 
	ca65 -D VMORG='$$$(VMORG)' -g -l $(basename $<).lst $<