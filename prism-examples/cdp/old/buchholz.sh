#!/bin/bash

propertie='P<0.5 [ true U<=1000 "observe" ]'

combinations=(
	"10 5"
	"10 6"
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

	cd ../../prism-extension/prism4.8.1/prism/bin/

	# PRISM Buchholz  
	echo "PRISM Buchholz for $DIR"
	echo -n "PRISM,Buchholz" >> "/tmp/cdp/$DIR/time.csv"
	for i in $(seq 1 50); do
		(time -p ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time.csv"	
	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done


