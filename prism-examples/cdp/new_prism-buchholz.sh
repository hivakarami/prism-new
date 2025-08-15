#!/bin/bash

# Number of iterations
num_iterations=50

propertie='P<0.5 [ true U<=10000 "observe" ]'

# Define the combinations of N and R
combinations=(
	"15 6"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"

	
	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra  > "/tmp/cdp/$DIR/prism-model-output"

	cd ../../prism-extension/prism-new/prism/prism/bin/	
	
	
	# PRISM Buchholz  
	rm "/tmp/cdp/$DIR/time_Buchholz.csv"
	echo "PRISM Buchholz for $DIR"
	echo -n "PRISM,Buchholz" >> "/tmp/cdp/$DIR/time_Buchholz.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -Buchholz -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time_Buchholz.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time_Buchholz.csv"	

	./prism -javamaxmem 3000m -Buchholz -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done


