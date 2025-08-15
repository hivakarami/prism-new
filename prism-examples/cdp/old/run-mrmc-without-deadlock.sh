if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <N> <R>"
    exit 1
fi

N=$1
R=$2
DIR="${N}-${R}"


prism cdp.pm cdp.pctl -const CrowdSize=$N,TotalRuns=$R -exportmrmc -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra"
cd $DIR
python3 mrmc-delete-deadlock.py
cd ..
mrmc -ilump dtmc "$DIR/cdp.tra" "$DIR/without-deadlock.lab" < input
