# HPC scheduler detected.
if [[ -n "$HPC_SCHEDULER" ]]; then
    echo "$HPC_SCHEDULER"
fi

# Check for supported operating system.
# Alternatively can use `$(uname -s)`
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OSNAME="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OSNAME="macOS"
else
    echo "${OSTYPE} operating system not supported"
    exit 1
fi
