# Kill all running bsub requests
if [[ -n $ORCHESTRA ]]; then
    bkill 0
else
    echo "Not running on Orchestra"
    exit 1
fi
