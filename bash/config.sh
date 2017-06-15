# PATH ====
echo "PATH exports"

# orchestra
if [[ -n $ORCHESTRA ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] orchestra modules"

# conda
if [[ ! -z $CONDA_DIR ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] conda"

# aspera connect
if [[ ! -z $ASPERA_DIR ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] aspera connect"

# bcbio-nextgen
if [[ ! -z $BCBIO_DIR ]]; then
    check="x"
else
    check=" "
fi
echo "    [$check] bcbio-nextgen"
