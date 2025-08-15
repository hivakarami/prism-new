#!/bin/bash
MAIN="/eecs/research/discoveri/summer24/prism-examples/rme"


for dir in */; do
    if [ -d "$dir" ]; then
		mkdir /tmp/rme1/$dir
		cd /cs/fac/packages/prism-new/prism/bin
	
    		#make prism model
    		echo "Building PRISM model"

		prism $MAIN/$dir/rme.pm -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme1/$dir/prism-model-output"

		rm "/tmp/rme1/$dir/time.csv"
		echo "2025-04-01" >> "/tmp/rme1/$dir/time.csv"

		# PRISM without
		echo "PRISM without for $dir"
		echo -n "PRISM,without" >> "/tmp/rme1/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p ./prism -javamaxmem 3000m -explicit -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab $MAIN/rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time.csv"
		done

		echo "" >> "/tmp/rme1/$dir/time.csv"

		# PRISM standard
		echo "PRISM standard for $dir"
		echo -n "PRISM,standard" >> "/tmp/rme1/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p ./prism -javamaxmem 3000m -explicit -bisim -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab $MAIN/rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time.csv"
		done

		#make MRMC model
		echo "Building MRMC model"

		prism $MAIN/$dir/rme.pm -dtmc -exportmrmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme1/$dir/mrmc-model-output"

		echo "" >> "/tmp/rme1/$dir/time.csv"

		# MRMC without
		echo "MRMC without for $dir"
		echo -n "MRMC,without" >> "/tmp/rme1/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p mrmc dtmc /tmp/rme.tra /tmp/rme.lab < $MAIN/input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time.csv"
		done

		echo "" >> "/tmp/rme1/$dir/time.csv"

		# MRMC standard
		echo "MRMC standard for $dir"
		echo -n "MRMC,standard" >> "/tmp/rme1/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p mrmc dtmc -ilump /tmp/rme.tra /tmp/rme.lab < $MAIN/input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme1/$dir/time.csv"
		done

		echo "" >> "/tmp/rme1/$dir/time.csv"

		cd $MAIN
    fi
done

