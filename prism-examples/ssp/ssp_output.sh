#!/bin/bash
for dir in */; do
	if [ -d "$dir" ]; then
		echo "$dir"
		cat "/tmp/ssp/$dir/time.csv"
		echo ""
	fi
done
