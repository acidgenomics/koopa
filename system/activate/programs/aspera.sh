#!/bin/sh
# shellcheck disable=SC2236

# Include Aspera Connect binaries in PATH, if defined.
# Modified 2019-06-20.

if [ -z "${ASPERACONNECT_EXE:-}" ]
then
    exe_file="${HOME}/.aspera/connect/bin/asperaconnect"
    if [ -f "$exe_file" ]
    then
        export ASPERACONNECT_EXE="$exe_file"
    else
        ASPERACONNECT_EXE=
    fi
    unset -v exe_file
fi
if [ -f "${ASPERACONNECT_EXE:-}" ]
then
    bin_dir="$(dirname "$ASPERACONNECT_EXE")"
    export PATH="${bin_dir}:${PATH}"
    unset -v bin_dir
fi

