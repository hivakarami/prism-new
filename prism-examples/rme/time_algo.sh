#!/bin/bash

#for dir in */; do
 #   if [ -d "$dir" ]; then
    	#make prism model
	dir="6"
    	echo "Building PRISM model"
    	
		prism -javamaxmem 6g $dir/rme.pm -dtmc -exportlabels /tmp/rme1.lab -exporttrans /tmp/rme1.tra > "/tmp/rme1/$dir/prism-model-output1"

		rm "/tmp/rme1/$dir/time1.csv"
                touch "/tmp/rme1/$dir/time1.csv"
		# PRISM standard
		#$echo "PRISM standard for $dir"
		#echo -n "PRISM,standard" >> "/tmp/rme1/$dir/time1.csv"
		#prism -explicit -bisim -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab -pf "$propertie" -dtmc | grep "Minimisation:"

		cd ../../prism-extension/prism4.8.1/prism/bin/
		
		# PRISM DerisaviRedBlack	
		 echo "PRISM DerisaviRedBlack for $dir"
		 echo -n "PRISM,DerisaviRedBlack" >> "/tmp/rme1/$dir/time1.csv"
		 for i in $(seq 1 20); do
			(time -p ./prism -javamaxmem 15000m -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/rme1.tra -importlabels /tmp/rme1.lab /eecs/research/discoveri/summer24/prism-examples/rme/rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time1.csv"
		 done
		 echo "" >> "/tmp/rme1/$dir/time1.csv"
		
		# PRISM DerisaviSplayTree	
		 echo "PRISM DerisaviSplayTree for $dir"
		 echo -n "PRISM,DerisaviSplayTree" >> "/tmp/rme1/$dir/time1.csv"
		 for i in $(seq 1 20); do
			(time -p ./prism -javamaxmem 15000m -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/rme1.tra -importlabels /tmp/rme1.lab /eecs/research/discoveri/summer24/prism-examples/rme/rme.pctl -dtmc ) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time1.csv"
		 done
		 echo "" >> "/tmp/rme1/$dir/time1.csv"


		# PRISM Valmari	
		echo "PRISM Valmari for $dir"
		echo -n "PRISM,Valmari" >> "/tmp/rme1/$dir/time1.csv"
		for i in $(seq 1 20); do
			(time -p ./prism -javamaxmem 15000m -algo explicit.Valmari -explicitbuild -importtrans /tmp/rme1.tra -importlabels /tmp/rme1.lab /eecs/research/discoveri/summer24/prism-examples/rme/rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time1.csv"
		done
		echo "" >> "/tmp/rme1/$dir/time1.csv"
		
		cd /eecs/research/discoveri/summer24/prism-examples/rme
		
		# PRISM Buchholz        
                echo "PRISM Buchholz for $dir"
                echo -n "PRISM,Buchholz" >> "/tmp/rme1/$dir/time1.csv"
                for i in $(seq 1 20); do
                        (time -p ./prism -javamaxmem 15000m -algo explicit.Buchholz -explicitbuild -importtrans /tmp/rme1.tra -importlabels /tmp/rme1.lab /eecs/research/discoveri/summer24/prism-examples/rme/rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time1.csv"
                done
                echo "" >> "/tmp/rme1/$dir/time1.csv"

   # fi
#done


