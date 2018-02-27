# http://www.biogrids.org
if [[ $HPC == "HMS RC Orchestra" ]]; then
    if [[ -f /programs/biogrids.shrc ]]; then
        source /programs/biogrids.shrc
    fi
else
    echo "Orchestra HPC required"
    return 1
fi
