#!/bin/bash

propertie='P>0.5 [ true U<=5000 "leader_elected" ]'

# Number of iterations
num_iterations=50

# Define the combinations of N and R
combinations=(
	"4-2"
	"4-4"
	"4-8"
	"5-2"
	"5-4"
	"5-6"
	"5-8"
    "4-16"
)


# Loop through each combination
for combo in "${combinations[@]}"; do
    DIR="$combo"
    
	#make prism model
	echo "Building PRISM model"
	prism $DIR/lep.pm -dtmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > "/tmp/lep/$DIR/prism-model-output"

	cd ../../prism-extension/prism-new/prism/prism/bin/	

	# PRISM Valmari  
	rm "/tmp/lep/$DIR/time_Valmari.csv"
	echo -n "PRISM,Valmari" >> "/tmp/lep/$DIR/time_Valmari.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -Valmari -explicit  -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time_Valmari.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time_Valmari.csv"	

	./prism -Valmari -explicit  -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/lep
done
