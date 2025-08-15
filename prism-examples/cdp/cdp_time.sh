#!/bin/bash

# Number of iterations
num_iterations=50

# Enable or disable test commands
test=true

# Define the combinations of N and R
#combinations=(
#	"5 3"
#	"5 4"
#	"5 5"
#	"5 6"
#	"10 3"
#	"10 4"
#	"10 5"
#	"10 6"
#	"15 3"
#	"15 4"
#	"15 5"
#	"15 6" 
#)

combinations=(
		"5 6"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"
	mkdir /tmp/cdp1/$DIR
   MAIN="/eecs/research/discoveri/summer24/prism-examples/cdp"
	cd /cs/fac/packages/prism-new/prism/bin
	
	
	#make prism model
	echo "Building PRISM model for $DIR"
	prism "$MAIN/cdp.pm" -const CrowdSize=$N,TotalRuns=$R -exportlabels "$MAIN/$DIR/cdp.lab" -exporttrans "$MAIN/$DIR/cdp.tra"  > "/tmp/cdp1/$DIR/prism-model-output"

	rm "/tmp/cdp1/$DIR/time.csv"
	echo "2025-04-01" >> "/tmp/cdp1/$DIR/time.csv"
		
	# PRISM without
	echo "PRISM without for $DIR"
	echo -n "PRISM,without" >> "/tmp/cdp1/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -explicit -importtrans "$MAIN/$DIR/cdp.tra" -importlabels "$MAIN/$DIR/cdp.lab" "$MAIN/cdp.pctl" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp1/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp1/$DIR/time.csv"
	
	# Testing the correctness of PRISM without
	if [ "$test" = true ]; then
        ./prism -javamaxmem 3000m -explicit -importtrans "$MAIN/$DIR/cdp.tra" -importlabels "$MAIN/$DIR/cdp.lab" "$MAIN/cdp.pctl" -dtmc > "/tmp/cdp1/$DIR/prism-run-output"
    fi
	

	# PRISM standard
	echo "PRISM standard for $DIR"
	echo -n "PRISM,standard" >> "/tmp/cdp1/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -javamaxmem 3000m -bisim -explicit -importtrans "$MAIN/$DIR/cdp.tra" -importlabels "$MAIN/$DIR/cdp.lab" "$MAIN/cdp.pctl" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp1/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp1/$DIR/time.csv"
	
	# Testing the correctness of PRISM standard
	if [ "$test" = true ]; then
        ./prism -javamaxmem 3000m -bisim -explicit -importtrans "$MAIN/$DIR/cdp.tra" -importlabels "$MAIN/$DIR/cdp.lab" "$MAIN/cdp.pctl" -dtmc | grep "Minimisation:" 
    fi

	#make MRMC model
	echo "Building MRMC model for $DIR"
	prism "$MAIN/cdp.pm" "$MAIN/cdp.pctl" -const CrowdSize=$N,TotalRuns=$R -exportmrmc -exportlabels "$MAIN/$DIR/cdp.lab" -exporttrans "$MAIN/$DIR/cdp.tra" > "/tmp/cdp1/$DIR/mrmc-model-output"
	cd $MAIN/$DIR
	python3 mrmc-delete-deadlock.py
	cd $MAIN

	# MRMC without
	echo "MRMC without for $DIR"
	echo -n "MRMC,without" >> "/tmp/cdp1/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc dtmc "$MAIN/$DIR/cdp.tra" "$MAIN/$DIR/without-deadlock.lab" < $MAIN/input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp1/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp1/$DIR/time.csv"
	
	# Testing the correctness of MRMC without
	if [ "$test" = true ]; then
        mrmc dtmc "$MAIN/$DIR/cdp.tra" "$MAIN/$DIR/without-deadlock.lab" < $MAIN/input > "/tmp/cdp1/$DIR/mrmc-run-output"
    fi

	# MRMC standard
	echo "MRMC standard for $DIR"
	echo -n "MRMC,standard" >> "/tmp/cdp1/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc -ilump dtmc "$MAIN/$DIR/cdp.tra" "$MAIN/$DIR/without-deadlock.lab" < $MAIN/input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp1/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp1/$DIR/time.csv"
	
	
	# Testing the correctness of MRMC standard
	if [ "$test" = true ]; then
        mrmc -ilump dtmc "$MAIN/$DIR/cdp.tra" "$MAIN/$DIR/without-deadlock.lab" < $MAIN/input |  grep "Lumping:" 
    fi

done

