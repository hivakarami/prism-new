#!/bin/bash

propertie='P>0.5 [ "notEnter1" U<=10000 "enter1" ]'

# Number of iterations
num_iterations=50

# Define the combinations of N and R
combinations=(
	"5"
)


# Loop through each combination
for combo in "${combinations[@]}"; do
    DIR="$combo"
    
	#make prism model
	echo "Building PRISM model"
	prism $DIR/rme.pm -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$DIR/prism-model-output"


	cd ../../prism-extension/prism-new/prism/prism/bin/	

	# PRISM Buchholz
	rm "/tmp/rme/$DIR/time_Buchholz.csv"
	echo -n "PRISM,Buchholz" >> "/tmp/rme/$DIR/time_Buchholz.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -Buchholz -explicit  -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time_Buchholz.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time_Buchholz.csv"	

	./prism -javamaxmem 3000m -Buchholz -explicit  -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/rme
done

