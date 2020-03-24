#/usr/bin/bash

#/usr/bin/time -v  ./smp_mad_stress -C mlx5_3  -T 1000 -r 0 -m 1 -N 256 -n 1  -t 10 -L 10,8,16,4,11,3,15,9 0x15 1  1
LID=${LID:="10,8,16,4,11,3,15,9"}
#ATTR=${ATTR:="0x10 0x11 0x12 0x14 0x15 0x16 0x17 0x18 0x19 0x1A 0x1B 0x33"}
#ATTR=${ATTR:="0x19"}
ATTR=${ATTR:="0xff22"}

echo $LID

for method in {2..2}; do
	echo "Method: $method"
	for attr in $ATTR; do
		echo "Attr: $attr"
		for N in {64..256..32}; do
			for n in {1..64}; do
				echo "n: $n"
				./smp_mad_stress -C mlx5_2  -p 3 -m $method -N 128  -n $n  -t 10 -L 123,104,34,79,80,133,21,31,26,30,36,43,9,152,157 0xff22 1  1
			done
		done
	done
done
