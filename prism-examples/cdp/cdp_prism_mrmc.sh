#!/bin/bash

# Number of iterations
num_iterations=1

# Enable or disable test commands
test=true

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
	echo "Building PRISM model for $DIR"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra"  > "/tmp/cdp/$DIR/prism-model-output"

	rm "/tmp/cdp/$DIR/time.csv"
		
	# PRISM without
	echo "PRISM without for $DIR"
	echo -n "PRISM,without" >> "/tmp/cdp/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p prism -javamaxmem 3000m -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"
	
	# Testing the correctness of PRISM without
	if [ "$test" = true ]; then
        prism -javamaxmem 3000m -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc > "/tmp/cdp/$DIR/prism-run-output"
    fi
	

	# PRISM standard
	echo "PRISM standard for $DIR"
	echo -n "PRISM,standard" >> "/tmp/cdp/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p prism -javamaxmem 3000m -bisim -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"
	
	# Testing the correctness of PRISM standard
	if [ "$test" = true ]; then
        prism -javamaxmem 3000m -bisim -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc | grep "Minimisation:" 
    fi

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

