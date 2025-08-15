#!/bin/bash

# Check if the user provided a directory argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

dir="$1"

#make prism model
echo "Building PRISM model"

prism $dir/rme.pm -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$dir/prism-model-output"

rm "/tmp/rme/$dir/time.csv"

# PRISM without
echo "PRISM without for $dir"
echo -n "PRISM,without" >> "/tmp/rme/$dir/time.csv"

for i in $(seq 1 50); do
	(time -p prism -javamaxmem 9000m -explicit -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$dir/time.csv"
done

echo "" >> "/tmp/rme/$dir/time.csv"

# PRISM standard
echo "PRISM standard for $dir"
echo -n "PRISM,standard" >> "/tmp/rme/$dir/time.csv"

for i in $(seq 1 50); do
	(time -p prism -javamaxmem 9000m -explicit -bisim -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$dir/time.csv"
done

#make MRMC model
echo "Building MRMC model"

prism $dir/rme.pm rme.pctl -dtmc -exportmrmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$dir/mrmc-model-output"

echo "" >> "/tmp/rme/$dir/time.csv"

# MRMC without
echo "MRMC without for $dir"
echo -n "MRMC,without" >> "/tmp/rme/$dir/time.csv"

for i in $(seq 1 50); do
	(time -p mrmc dtmc /tmp/rme.tra /tmp/rme.lab < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$dir/time.csv"
done

echo "" >> "/tmp/rme/$dir/time.csv"

# MRMC standard
echo "MRMC standard for $dir"
echo -n "MRMC,standard" >> "/tmp/rme/$dir/time.csv"

for i in $(seq 1 50); do
	(time -p mrmc dtmc -ilump /tmp/rme.tra /tmp/rme.lab < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/rme/$dir/time.csv"
done

echo "" >> "/tmp/rme/$dir/time.csv"


