#/usr/bin/bash

LID=${LID:="3"}
ATTR=${ATTR:="0x10 0x11 0x12 0x14 0x15 0x16 0x17 0x18 0x19 0x1A 0x1B 0x33"}
#ATTR=${ATTR:="0x19"}

echo $LID

for method in {1..2}; do
	echo "Method: $method"
	for attr in $ATTR; do
		echo "Attr: $attr"
		for n in {1,2,4,8,16}; do
			echo "n: $n"
			./build/bin/smpdump -C mlx5_3  -m $method -N 128 -n $n  -t 20 -L $LID $attr 1  1
		done
	done
done
