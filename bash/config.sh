# PATH ====
echo "PATH exports"
# conda
if [[ ! -z $conda_dir ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] conda"

# orchestra
if [[ -n $orchestra ]] && [[ -z $conda_dir ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] orchestra modules"

# bcbio-nextgen
if [[ ! -z $bcbio_dir ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] bcbio-nextgen"
