# http://www.biogrids.org
if [[ -n $ORCHESTRA ]]; then
    if [[ -f /programs/biogrids.shrc ]]; then
        source /programs/biogrids.shrc
    fi
else
    echo "Not running on Orchestra"
    exit 1
fi
