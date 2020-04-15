CC=gcc

smp_mad_stress: smpdump.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -o smp_mad_stress ibdiag_common.c smpdump.c -libumad -libmad -lpthread -I/usr/include/infiniband  -std=gnu99 -g -O0
