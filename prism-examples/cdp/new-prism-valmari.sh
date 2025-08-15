#!/bin/bash

# Number of iterations
num_iterations=200

propertie='P<0.5 [ true U<=10000 "observe" ]'

# Define the combinations of N and R
combinations=(
	"5 5"
	"5 6"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"

	
	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra  > "/tmp/cdp/$DIR/prism-model-output"

	cd ../../prism-extension/prism-new/prism/prism/bin/	
	
	
	# PRISM Valmari  
	rm "/tmp/cdp/$DIR/time_Valmari.csv"
	echo "PRISM Valmari for $DIR"
	echo -n "PRISM,Valmari" >> "/tmp/cdp/$DIR/time_Valmari.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -Valmari -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time_Valmari.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time_Valmari.csv"	

	./prism -javamaxmem 3000m -Valmari -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done

