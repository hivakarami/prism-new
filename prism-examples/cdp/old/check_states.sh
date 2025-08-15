#!/bin/bash

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
	"15 6"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"
	
	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra"  > "/tmp/cdp/$DIR/prism-model-output"
	prism -javamaxmem 3000m -explicit -bisim -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc  | grep "Minimisation:"
	

	#make MRMC model
	echo "Building MRMC model"
	prism cdp.pm cdp.pctl -const CrowdSize=$N,TotalRuns=$R -exportmrmc -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra" > "/tmp/cdp/$DIR/mrmc-model-output"
	cd $DIR
	python3 mrmc-delete-deadlock.py
	cd ..
	mrmc dtmc -ilump "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input | grep "Lumping:"


done


