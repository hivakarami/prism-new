#!/bin/bash

for dir in */1719; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"

		prism $dir/ssp.pm -dtmc -exportlabels /tmp/ssp.lab -exporttrans /tmp/ssp.tra > "/tmp/ssp/$dir/prism-model-output"

		rm "/tmp/ssp/$dir/time.csv"

		# PRISM without
		echo "PRISM without for $dir"
		echo -n "PRISM,without" >> "/tmp/ssp/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p prism -javamaxmem 99999m -explicit -importtrans /tmp/ssp.tra -importlabels /tmp/ssp.lab ssp.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/ssp/$dir/time.csv"
		done

		echo "" >> "/tmp/ssp/$dir/time.csv"

		# PRISM standard
		echo "PRISM standard for $dir"
		echo -n "PRISM,standard" >> "/tmp/ssp/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p prism -javamaxmem 99999m -explicit -bisim -importtrans /tmp/ssp.tra -importlabels /tmp/ssp.lab ssp.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/ssp/$dir/time.csv"
		done

		#make MRMC model
		echo "Building MRMC model"

		prism $dir/ssp.pm -dtmc -exportmrmc -exportlabels /tmp/ssp.lab -exporttrans /tmp/ssp.tra > "/tmp/ssp/$dir/mrmc-model-output"

		echo "" >> "/tmp/ssp/$dir/time.csv"

		# MRMC without
		echo "MRMC without for $dir"
		echo -n "MRMC,without" >> "/tmp/ssp/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p mrmc dtmc /tmp/ssp.tra /tmp/ssp.lab < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/ssp/$dir/time.csv"
		done

		echo "" >> "/tmp/ssp/$dir/time.csv"

		# MRMC standard
		echo "MRMC standard for $dir"
		echo -n "MRMC,standard" >> "/tmp/ssp/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p mrmc dtmc -ilump /tmp/ssp.tra /tmp/ssp.lab < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/ssp/$dir/time.csv"
		done

		echo "" >> "/tmp/ssp/$dir/time.csv"
    fi
done

