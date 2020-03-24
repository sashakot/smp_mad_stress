#/usr/bin/bash

#/usr/bin/time -v  ./smp_mad_stress -C mlx5_3  -T 1000 -r 0 -m 1 -N 256 -n 1  -t 10 -L 10,8,16,4,11,3,15,9 0x15 1  1
LID=${LID:="10,8,16,4,11,3,15,9"}
#ATTR=${ATTR:="0x10 0x11 0x12 0x14 0x15 0x16 0x17 0x18 0x19 0x1A 0x1B 0x33"}
#ATTR=${ATTR:="0x19"}
ATTR=${ATTR:="0x15"}

echo $LID

for method in {1..1}; do
	echo "Method: $method"
	for attr in $ATTR; do
		echo "Attr: $attr"
		for n in {8..8}; do
			echo "n: $n"
			./smp_mad_stress -C mlx5_3  -m $method -N 128 -n $n  -t 20 -L $LID $attr 1  1 > ./out1.log &2>1 &
			./smp_mad_stress -C mlx5_3  -m $method -N 128 -n $n  -t 20 -L $LID $attr 1  1 > ./out2.log &2>1 &
			./smp_mad_stress -C mlx5_3  -m $method -N 128 -n $n  -t 20 -L $LID $attr 1  1 > ./out3.log &2>1
		done
	done
done
