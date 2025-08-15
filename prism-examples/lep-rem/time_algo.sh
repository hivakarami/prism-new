#!/bin/bash

propertie='P>0.5 [ true U<=5000 "leader_elected" ]'

for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model $dir"
    	
		prism $dir/lep.pm -dtmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > "/tmp/lep/$dir/prism-model-output"

		rm "/tmp/lep/$dir/time.csv"

		# PRISM standard
		#$echo "PRISM standard for $dir"
		#echo -n "PRISM,standard" >> "/tmp/lep/$dir/time.csv"
		#prism -explicit -bisim -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:"

		cd ../../../prism-extension/prism4.8.1/prism/bin/
		
				
		# PRISM Buchholz	
		#echo "PRISM Buchholz for $dir"
		#echo -n "PRISM,Buchholz" >> "/tmp/lep/$dir/time.csv"
		#for i in $(seq 1 20); do
		#	(time -p ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie"-dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$dir/time.csv"
		#done
		
		#echo "" >> "/tmp/lep/$dir/time.csv"
		
		# PRISM DerisaviRedBlack	
		echo "PRISM DerisaviRedBlack for $dir"
		echo -n "PRISM,DerisaviRedBlack" >> "/tmp/lep/$dir/time.csv"
		for i in $(seq 1 10); do
			(time -p ./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$dir/time.csv"
		done
		echo "" >> "/tmp/lep/$dir/time.csv"
		
		# PRISM DerisaviSplayTree	
		echo "PRISM DerisaviSplayTree for $dir"
		echo -n "PRISM,DerisaviSplayTree" >> "/tmp/lep/$dir/time.csv"
		for i in $(seq 1 20); do
			(time -p ./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc ) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$dir/time.csv"
		done
		echo "" >> "/tmp/lep/$dir/time.csv"


		# PRISM Valmari	
		#echo "PRISM Valmari for $dir"
		#echo -n "PRISM,Valmari" >> "/tmp/lep/$dir/time.csv"
		#for i in $(seq 1 20); do
		#	(time -p ./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$dir/time.csv"
		#done
		#echo "" >> "/tmp/lep/$dir/time.csv"
		
		cd /eecs/research/discoveri/summer24/prism-examples/lep/rem
		
    fi
done

