#!/bin/bash

# Number of iterations
num_iterations=50

propertie='P<0.5 [ true U<=10000 "observe" ]'

# Define the combinations of N and R
combinations=(
		"5 3"
	"5 4"
	"5 5"
	"5 6"
	"10 3"
	"10 4"
	"10 5"
	"10 6"
	"15 3"
	"15 4"
	"15 5"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"

	
	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra  > "/tmp/cdp/$DIR/prism-model-output"

	cd ../../prism-extension/prism-new/prism/prism/bin/	
	
	
	# PRISM DerisaviRedBlack  
	rm "/tmp/cdp/$DIR/time_DerisaviRedBlack.csv"
	echo "PRISM DerisaviRedBlack for $DIR"
	echo -n "PRISM,DerisaviRedBlack" >> "/tmp/cdp/$DIR/time_DerisaviRedBlack.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -DerisaviRedBlack -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time_DerisaviRedBlack.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time_DerisaviRedBlack.csv"	

	./prism -javamaxmem 3000m -DerisaviRedBlack -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done

