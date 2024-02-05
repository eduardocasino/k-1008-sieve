## Visible primes
Visually displays distribution of the prime numbers between 1 and 128000 (except for "2") using a sieve algorithm.

Requires a KIM-1 with a K-1008 Visable Memory Card.

Based on the description of a similar program that MTU's Hal Chamberlin wrote for the MTU-130.

The Intel hex and pap files load at 0x0400 and assume K-1008 at 0xA000. You can edit the "START" and "VMORG" variables in the Makefile to suit your setup.

Be sure your interrupt vector (at 0x17FE and 0x17FF) is set to address 0x1C00.

### Algorithm

Graphic RAM pixels are assigned to odd integers, beginning with 1 and plotted from top left to bottom right. The K-1008 has a resolution of 320x200 pixels, so it can hold 64000 odd numbers (from 1 to 127999)

First, all of the pixels are set to 1.

Starting with 3, for each odd number N that has its corresponding pixel set, find its multiples recursively advancing N positions on the screen and unset them.

Repeat until N is greater than the square root of 127999.

### No license

This program is in the **PUBLIC DOMAIN**.
