#!/bin/bash

# Number of iterations
num_iterations=1

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
	
	./prism -javamaxmem 3000m -bisim -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation" # test

	
	# PRISM Standard  
	rm "/tmp/cdp/$DIR/time_Standard.csv"
	echo "PRISM Standard for $DIR"
	echo -n "PRISM,Standard" >> "/tmp/cdp/$DIR/time_Standard.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -bisim -javamaxmem 3000m -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time_Standard.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time_Standard.csv"	

	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done
# ./prism -javamaxmem 3000m -explicit -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf 'P<0.5 [ true U<=10000 "observe" ]' -dtmc 

