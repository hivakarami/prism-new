#!/bin/bash

propertie='P>0.5 [ "notEnter1" U<=500 "enter1" ]'

# Number of iterations
num_iterations=50

# Define the combinations of N and R
combinations=(
	"3"
	"4"
	"5"
)


# Loop through each combination
for combo in "${combinations[@]}"; do
    DIR="$combo"
    
	#make prism model
	echo "Building PRISM model"
	prism $DIR/rme.pm -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$DIR/prism-model-output"


	cd ../../prism-extension/prism-new/prism/prism/bin/	

	# PRISM Valmari
	rm "/tmp/rme/$DIR/time_Valmari.csv"
	echo -n "PRISM,Valmari" >> "/tmp/rme/$DIR/time_Valmari.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -Valmari -explicit  -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time_Valmari.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time_Valmari.csv"	

	./prism -javamaxmem 3000m -Valmari -explicit  -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/rme
done

