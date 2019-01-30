#!/bin/ssh
# shellcheck disable=SC2236

# Include bcbio toolkit binaries in PATH, if defined.
# Attempt to locate bcbio installation automatically on supported platforms.

if [ -z "$BCBIO_EXE" ]
then
    if [ ! -z "$HARVARD_O2" ]
    then
        export BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [ ! -z "$HARVARD_ODYSSEY" ]
    then
        export BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    fi
fi
if [ ! -z "$BCBIO_EXE" ]
then
    # Check that path is valid.
    if [ -f "$BCBIO_EXE" ]
    then
        bcbio_bin_dir="$( dirname "$BCBIO_EXE" )"
        export PATH="${bcbio_bin_dir}:${PATH}"
        unset -v PYTHONHOME PYTHONPATH
        unset -v bcbio_bin_dir
    else
        printf "bcbio does not exist at:\n%s\n" "$BCBIO_EXE"
        # Don't exit here as this can cause SSH lockout.
    fi
fi
