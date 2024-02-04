## Visible primes
Visually displays distribution of the prime numbers between 1 and 128000 (except for "2") using a sieve algorithm.

Requires a KIM-1 with a K-1008 Visable Memory Card.

Based on the description of a similar program that MTU's Hal Chamberlin wrote for the MTU-130.

The Intel hex and pap files load at 0x0400 and assume K-1008 at 0xA000. You can edit the "START" and "VMORG" variables in the Makefile to suit your setup.

Be sure your interrupt vector (at l7FE and 17FF) is set to address $1C00.

This program is in the **PUBLIC DOMAIN**.