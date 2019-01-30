#!/bin/ssh
# shellcheck disable=SC2236

# Include Aspera Connect binaries in PATH, if defined.

if [ -z "$ASPERACONNECT_EXE" ]
then
    aspera_exe="${HOME}/.aspera/connect/bin/asperaconnect"
    if [ -f "$aspera_exe" ]
    then
        export ASPERACONNECT_EXE="$aspera_exe"
        unset -v aspera_exe
    else
        ASPERACONNECT_EXE=0
    fi
fi
if [ -f "ASPERACONNECT_EXE" ]
then
    aspera_bin_dir="$( dirname "$ASPERACONNECT_EXE" )"
    export PATH="${aspera_bin_dir}:${PATH}"
    unset -v aspera_bin_dir
fi
