#!/bin/bash
for dir in */; do
	if [ -d "$dir" ]; then
		echo "$dir"
		cat "/tmp/rme/$dir/time.csv"
		echo ""
	fi
done
