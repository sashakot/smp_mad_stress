SMP MAD stress tester
---------------------

This tool is based on [smpdump](https://github.com/linux-rdma/rdma-core/blob/master/infiniband-diags/smpdump.c)

## Dependencies

1. libibumad
2. pthread

## How to build

``` bash
$ make
```

## Overview

smp_mad_stress manages a queue of MADs on wire per destination device and SMP window in local device as well. In other words, it limits a number of SMP MADs sent to each destination and total number of MADs sent from local port.
Send and receive are done from the same thread using "poll" technique.

The tool can run as distributed application based on MPI (needs compilation with special flag, see example below). In this case, before each  sending all ranks go to a barrier. It will work only if we use single desitnation and single worker.

## Testing results

### SMP MAD latency

Switch: "Quantum" (227.2007.300), SMP: LinearForwardingTable (0x19), Lid route

| Destination queue depth | MAD/s |
|-------------------------|-------|
| 1                       | 4500  |
| 2                       | 5700  |

Queue depth [3..20] doesn't improve performance, the result is same : 5700 MADs/s. After queue 20 VL15Dropped grows in destination.

If we send LinearForwardingTable (0x19) SET one by one average latency is about 255us which includes about 220-230us round-trip in network and in FW and ~20us in host SW (driver, user-space).

### CPU utilization

Testing machine:
```
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                16
On-line CPU(s) list:   0-15
Thread(s) per core:    1
Core(s) per socket:    8
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 79
Model name:            Intel(R) Xeon(R) CPU E5-2620 v4 @ 2.10GHz
Stepping:              1
CPU MHz:               2101.000
CPU max MHz:           2101.0000
CPU min MHz:           1200.0000
BogoMIPS:              4200.03
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              20480K
NUMA node0 CPU(s):     0-7
NUMA node1 CPU(s):     8-15
```

Test: sending NodeInfo (0x11) GET to all ports in the fabric.

| # of threads | CPU%     | MAD/s |
|--------------|----------|-------|
| 1            | 100%     | 185K  |
| 2            | 212%     | 212K  |
| 3            | 260%     | 260K  |

Increasing number of workers above 3 doesn't improve performance. Max performance seen in e2e is 300K MAD/s in 3-4 threads.

## Conclusions and observations

* Having more than two MADs on wire to the same destination doesn't help.
* Local device can send 128 MADs in parallel (1-2 MADs to each destination) without drops. 128 is default size of send queue for QP0 in driver
* MAD send/recv consume CPU. For reaching maximum, single thread is not enough


## Usage & Parameters

Usage: ./smp_mad_stress [options] <dlid|dr_path> <attr> [mod]

| Paramter     | Description                                          |
|--------------|------------------------------------------------------|
| -t           | Testing time in sec                                  |
| -C           | Local device                                         |
| -N           | Local queue depth                                    |
| -n           | Destination queue depth                              |
| -T           | umad timeout                                         |
| -r           | umad retries                                         |
| -m           | managment menthod : 1- SET (default), 2 - GET        |
| -p           | Number of workers (threads)                          |
| -L           | Destination lids, comma-separated list               |
| -X           | Max number of MADs for sending to a destination      |
| -M           | Print results in MPI frendly way (only rank#0 prints)|

## How to compile with MPI

``` bash
$ module load hpcx/v2.6/mofed5.0/gcc
$ make CFLAGS=-DHAVE_MPI CC=mpicc
```

## Examples
------

### Non - mpi examples

``` bash
 $ ./build/bin/smpdump -C mlx5_3  -m 2 -N 16  -t 20 -L 9 0x19 1  1
 $ ./smp_mad_stress -r 0 -T 1 -p 1 -m 1 -N 128  -n 10  -t 10 -L 24,18,30,23,34,53,57,58,59,3,56,8,7 0xff23 1
 ```

### MPI examples

``` bash
$ mpirun --bind-to core --map-by node  -hostfile hostlist   --oversubscribe -np 20  -mca btl self,vader,tcp -x LD_LIBRARY_PATH -mca pml ob1  -mca coll ^hcoll /hpc/scrap/users/sashakot/smp_mad_stress/smp_mad_stress  -C mlx5_2  -p 1 -m 129 -N 2048  -n 2048  -T 200 -r 1 -t 1 -M  -X 1 -L 117 0xff23 0

```

### Usefull commands
$ssh mngx-orion-01 squeue -u sashakot | grep sashakot | awk '{print $8}' | xargs hostlist -e > hostlist
``` bash

```

## Changing VL15 buffer for CX-5/6

Source: Yuval Atias

The example below assumes, we use port 0 and don't use VL3

``` bash
[yuvala@l-fwdev-092 ~]$ s /.autodirect/fwgwork/yuvala/tmp/negev_read_rx_credits.sh /dev/mst/mt4123_pciconf0
--- Each credit is 128 [B] ---
Port0 vl15 credits
0x00000008
Port0 dynamic credits
0x00000047
Port0 vl0 credits
0x000003ec
Port0 vl1 credits
0x000003ec
Port0 vl2 credits
0x000003ec
Port0 vl3 credits
0x000003ec

s /.autodirect/fwgwork/yuvala/tmp/negev_set_vl15_rx_stat_credits.sh /dev/mst/mt4123_pciconf0 10
--- Each credit is 128 [B] ---
setting Port0 vl15 credits to 10
setting Port0 vl3 credits to 0x100


[yuvala@l-fwdev-092 ~]$ s /.autodirect/fwgwork/yuvala/tmp/negev_set_dyn_rx_stat_credits.sh /dev/mst/mt4123_pciconf0 100
--- Each credit is 128 [B] ---
setting Port0 dynamic credits to 100
setting Port0 vl3 credits to 0x100

```

## Changing VL15 buffer for CX-4

Done, both for ConnectX-4 and ConnectX-6 you can use values of credits between 8-0x100.
Better to do the configuration when there is no traffic and fw reset to return back to default.

``` bash

[yuvala@l-fwdev-033 ~]$ s /.autodirect/fwgwork/yuvala/tmp/shomron_read_rx_credits.sh /dev/mst/mt4115_pciconf0
--- Each credit is 128 [B] ---
Port0 vl15 credits
0x00000008
Port0 dynamic credits
0x00000047
Port0 vl0 credits
0x000001ec
Port0 vl1 credits
0x000001ec
Port0 vl2 credits
0x000001ec
Port0 vl3 credits
0x000001ec

[yuvala@l-fwdev-033 ~]$ s /.autodirect/fwgwork/yuvala/tmp/shomron_set_rx_dyn_credits.sh /dev/mst/mt4115_pciconf0 40
--- Each credit is 128 [B] ---
setting Port0 dynamic credits to 40
setting Port0 vl3 credits to 0x20

[yuvala@l-fwdev-033 ~]$ s /.autodirect/fwgwork/yuvala/tmp/shomron_set_vl15_rx_stat_credits.sh /dev/mst/mt4115_pciconf0 0x100
--- Each credit is 128 [B] ---
setting Port0 vl15 credits to 0x100
setting Port0 vl3 credits to 0x20

```
