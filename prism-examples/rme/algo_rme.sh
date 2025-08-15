#!/bin/bash

propertie='P>0.5 [ "notEnter1" U<=500 "enter1" ]'

# Number of iterations
num_iterations=1

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

	cd ../../prism-extension/prism4.8.1/prism/bin/
	

	# PRISM Buchholz  
	rm "/tmp/rme/$DIR/time_Buchholz.csv"
	echo "PRISM Buchholz for $DIR"
	echo -n "PRISM,Buchholz" >> "/tmp/rme/$DIR/time_Buchholz.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time_Buchholz.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time_Buchholz.csv"	
	
	./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test
	
	# PRISM Valmari  
	rm "/tmp/rme/$DIR/time_Valmari.csv"
	echo "PRISM Valmari for $DIR"
	echo -n "PRISM,Valmari" >> "/tmp/rme/$DIR/time_Valmari.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time_Valmari.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time_Valmari.csv"	

	./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	# PRISM DerisaviSplayTree  
	rm "/tmp/rme/$DIR/time_DerisaviSplayTree.csv"
	echo "PRISM DerisaviSplayTree for $DIR"
	echo -n "PRISM,DerisaviSplayTree" >> "/tmp/rme/$DIR/time_DerisaviSplayTree.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time_DerisaviSplayTree.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time_DerisaviSplayTree.csv"	

	./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	
	# PRISM DerisaviRedBlack  
	rm "/tmp/rme/$DIR/time_DerisaviRedBlack.csv"
	echo "PRISM DerisaviRedBlack for $DIR"
	echo -n "PRISM,DerisaviRedBlack" >> "/tmp/rme/$DIR/time_DerisaviRedBlack.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$DIR/time_DerisaviRedBlack.csv"
	done
	echo "" >> "/tmp/rme/$DIR/time_DerisaviRedBlack.csv"	

	./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/rme
done
