#!/bin/bash

# Number of iterations
num_iterations=50

# Enable or disable test commands
test=true

# Define the combinations of N and R
combinations=(

	"10 6"
	"15 3"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"
	

	#make MRMC model
	echo "Building MRMC model for $DIR"
	prism cdp.pm cdp.pctl -const CrowdSize=$N,TotalRuns=$R -exportmrmc -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra" > "/tmp/cdp/$DIR/mrmc-model-output"
	cd $DIR
	python3 mrmc-delete-deadlock.py
	cd ..

	# MRMC without
	echo "MRMC without for $DIR"
	echo -n "MRMC,without" >> "/tmp/cdp/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"
	
	# Testing the correctness of MRMC without
	if [ "$test" = true ]; then
        mrmc dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input > "/tmp/cdp/$DIR/mrmc-run-output"
    fi

	# MRMC standard
	echo "MRMC standard for $DIR"
	echo -n "MRMC,standard" >> "/tmp/cdp/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc -ilump dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"
	
	
	# Testing the correctness of MRMC standard
	if [ "$test" = true ]; then
        mrmc -ilump dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input |  grep "Lumping:" 
    fi

done

