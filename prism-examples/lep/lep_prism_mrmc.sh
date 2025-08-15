#!/bin/bash

propertie='P>0.5 [ true U<=5000 "leader_elected" ]'

# Number of iterations
num_iterations=1

# Enable or disable test commands
test=true

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
	
	
	rm "/tmp/lep/$DIR/time.csv"
		
	# PRISM without
	echo "PRISM without for $DIR"
	echo -n "PRISM,without" >> "/tmp/lep/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p prism -explicit -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab lep.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time.csv"
	
	# Testing the correctness of PRISM without
	if [ "$test" = true ]; then
    	prism  -explicit -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab lep.pctl -dtmc > "/tmp/lep/$DIR/prism-run_output"
    fi
	

	# PRISM standard
	echo "PRISM standard for $DIR"
	echo -n "PRISM,standard" >> "/tmp/lep/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p prism -bisim -explicit -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab lep.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time.csv"
	
	# Testing the correctness of PRISM standard
	if [ "$test" = true ]; then
         prism -bisim -explicit -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab lep.pctl -dtmc | grep "Minimisation:" 
    fi

	#make MRMC model
	echo "Building MRMC model"
	prism $DIR/lep.pm -dtmc -exportmrmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > "/tmp/lep/$dir/mrmc-model-output"
	
	# MRMC without
	echo "MRMC without for $DIR"
	echo -n "MRMC,without" >> "/tmp/lep/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc dtmc /tmp/lep.lab /tmp/lep.tra < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time.csv"
	
	# Testing the correctness of MRMC without
	if [ "$test" = true ]; then
        mrmc dtmc /tmp/lep.lab /tmp/lep.tra < input > "/tmp/lep/$DIR/mrmc-run_output"
    fi

	# MRMC standard
	echo "MRMC standard for $DIR"
	echo -n "MRMC,standard" >> "/tmp/lep/$DIR/time.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p mrmc -ilump dtmc /tmp/lep.lab /tmp/lep.tra < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time.csv"
	
	
	# Testing the correctness of MRMC without
	if [ "$test" = true ]; then
        mrmc -ilump dtmc /tmp/lep.lab /tmp/lep.tra < input |  grep "Lumping:"
    fi
		
 
done


