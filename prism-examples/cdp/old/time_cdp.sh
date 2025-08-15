#!/bin/bash

# Define the combinations of N and R
combinations=(
    "10 5"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"
	
	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra"  > "/tmp/cdp/$DIR/prism-model-output"

	rm "/tmp/cdp/$DIR/time.csv"

	# PRISM without
	echo "PRISM without for $DIR"
	echo -n "PRISM,without" >> "/tmp/cdp/$DIR/time.csv"
	for i in $(seq 1 5); do
		(time -p prism -javamaxmem 3000m -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"

	# PRISM standard
	echo "PRISM standard for $DIR"
	echo -n "PRISM,standard" >> "/tmp/cdp/$DIR/time.csv"
	#prism -bisim -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc | grep "Minimisation:"
	for i in $(seq 1 5); do
		(time -p prism -javamaxmem 3000m -bisim -explicit -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"

	#make MRMC model
	echo "Building MRMC model"
	prism cdp.pm cdp.pctl -const CrowdSize=$N,TotalRuns=$R -exportmrmc -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra" > "/tmp/cdp/$DIR/mrmc-model-output"
	cd $DIR
	python3 mrmc-delete-deadlock.py
	cd ..


	# MRMC without
	echo "MRMC without for $DIR"
	echo -n "MRMC,without" >> "/tmp/cdp/$DIR/time.csv"

	for i in $(seq 1 50); do
		(time -p mrmc dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"

	# MRMC standard
	echo "MRMC standard for $DIR"
	echo -n "MRMC,standard" >> "/tmp/cdp/$DIR/time.csv"

	#mrmc -ilump dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input | grep "Lumping:"
	for i in $(seq 1 50); do
		(time -p mrmc -ilump dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"

done



