#!/bin/bash

propertie='P>0.5 [ true U<=5000 "leader_elected" ]'

# Number of iterations
num_iterations=1

# Define the combinations of N and R
combinations=(
	"4-2"
	"4-4"
)


# Loop through each combination
for combo in "${combinations[@]}"; do
    DIR="$combo"
    
	#make prism model
	echo "Building PRISM model"
	prism $DIR/lep.pm -dtmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > "/tmp/lep/$DIR/prism-model-output"

	cd ../../prism-extension/prism-new/prism/bin/

	
	# PRISM DerisaviRedBlack  
	rm "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"
	echo "PRISM DerisaviRedBlack for $DIR"
	echo -n "PRISM,DerisaviRedBlack" >> "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -DerisaviRedBlack -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"	

	./prism -DerisaviRedBlack -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/lep
done
