#!/bin/bash

echo "Create MRMC model for crowds protocol with CrowdSize=$1 and TotalRuns=$2"

prism cdp.pm cdp.pctl -const CrowdSize="$1",TotalRuns="$2" -exportmrmc -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra | grep -E "States|Transitions"

echo "Run MRMC reduction"

mrmc dtmc -ilump /tmp/cdp.tra /tmp/cdp.lab < input | grep "Lumping:"

echo "Create Prism model for crowds protocol with CrowdSize=$1 and TotalRuns=$2"

prism cdp.pm cdp.pctl -const CrowdSize="$1",TotalRuns="$2" -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra > /dev/null

echo "Run Prism reduction"

prism -explicit -bisim -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab cdp.pctl -dtmc | grep "Minimisation:"

