CC=gcc

smp_mad_stress:
	$(CC)  -o smp_mad_stress ibdiag_common.c smpdump.c -libumad -libmad -I/usr/include/infiniband
