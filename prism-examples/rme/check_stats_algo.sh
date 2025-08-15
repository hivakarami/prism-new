#!/bin/bash
for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"

		prism $dir/rme.pm rme.pctl -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme1/$dir/prism-model-output"

		# PRISM standard
		echo "PRISM standard for $dir"
                echo -n "PRISM,standard" >> "/tmp/rme1/$dir/time1.csv"
		output=$( { prism -javamaxmem 3000m -explicit -bisim -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc; } )
		Minimisation=$(echo "$output" | grep "Minimisation:")
		echo "Minimisation : $Minimisation"

               
                cd ../../prism-extension/prism4.8.1/prism/bin/
                # PRISM Buchholz
                echo "PRISM Buchholz for $dir"
		echo -n "PRISM,Buchholz" >> "/tmp/rme1/$dir/time1.csv"
		prism -javamaxmem 3000m -explicit -algo explicit.Buchholz -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc | grep "Minimisation:"
	        
                # PRISM DerisaviRedBlack
		echo "PRISM DerisaviRedBlack for $dir"
		echo -n "PRISM,DerisaviRedBlack" >> "/tmp/rme1/$dir/time1.csv"
		prism -javamaxmem 3000m -explicit -algo explicit.DerisaviRedBlack -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc | grep "Minimisation:" 
        	
		# PRISM DerisaviSplayTree
                echo "PRISM DerisaviSplayTree for $dir"
                echo -n "PRISM,DerisaviSplayTree" >> "/tmp/rme1/$dir/time1.csv"
                prism -javamaxmem 3000m -explicit -algo explicit.DerisaviSplayTree -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc | grep "Minimisation:"


                # PRISM Valmari
                echo "PRISM Valmari for $dir"
                echo -n "PRISM,Valmari" >> "/tmp/rme1/$dir/time1.csv"
                prism -javamaxmem 3000m -explicit -algo explicit.Valmari -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc | grep "Minimisation:"

		cd eecs/research/discoveri/summer24/prism-examples/rme
		pwd
		

    fi
done
