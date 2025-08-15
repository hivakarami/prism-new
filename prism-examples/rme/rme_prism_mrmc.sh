#!/bin/bash

# Number of iterations
num_iterations=1

# Enable or disable test commands
test=true

# Define the combinations of N and R
combinations=(
	"3"
	"4"
	"5"
	"6"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    DIR="$combo"
    
	#make prism model
	echo "Building PRISM model"
	prism $DIR/rme.pm -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$DIR/prism-model-output"
	
	
	rm "/tmp/rme/$DIR/time.csv"
		
	# PRISM without
	echo "PRISM without for $DIR"
	echo -n "PRISM,without" >> "/tmp/rme/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p prism -explicit -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time.csv"
	
	# Testing the correctness of PRISM without
	if [ "$test" = true ]; then
    	prism  -explicit -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc > "/tmp/rme/$DIR/prism-run_output"
    fi
	

	# PRISM standard
	echo "PRISM standard for $DIR"
	echo -n "PRISM,standard" >> "/tmp/rme/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p prism -bisim -explicit -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time.csv"
	
	# Testing the correctness of PRISM standard
	if [ "$test" = true ]; then
         prism -bisim -explicit -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc | grep "Minimisation:" 
    fi

	#make MRMC model
	echo "Building MRMC model"
	prism $DIR/rme.pm -dtmc -exportmrmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$dir/mrmc-model-output"
	
	# MRMC without
	echo "MRMC without for $DIR"
	echo -n "MRMC,without" >> "/tmp/rme/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc dtmc /tmp/rme.lab /tmp/rme.tra < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time.csv"
	
	# Testing the correctness of MRMC without
	if [ "$test" = true ]; then
        mrmc dtmc /tmp/rme.lab /tmp/rme.tra < input > "/tmp/rme/$DIR/mrmc-run_output"
    fi

	# MRMC standard
	echo "MRMC standard for $DIR"
	echo -n "MRMC,standard" >> "/tmp/rme/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc -ilump dtmc /tmp/rme.lab /tmp/rme.tra < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time.csv"
	
	
	# Testing the correctness of MRMC without
	if [ "$test" = true ]; then
        mrmc -ilump dtmc /tmp/rme.lab /tmp/rme.tra < input |  grep "Lumping:"
    fi
		
 
done


