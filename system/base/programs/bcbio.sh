#!/bin/sh
# shellcheck disable=SC2236

# Include bcbio toolkit binaries in PATH, if defined.
# Attempt to locate bcbio installation automatically on supported platforms.

if [ -z "$BCBIO_EXE" ]
then
    if [ ! -z "$AZURE" ]
    then
        BCBIO_EXE="/data00/bcbio/tools/bin/bcbio_nextgen.py"
    elif [ ! -z "$HARVARD_O2" ]
    then
        BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [ ! -z "$HARVARD_ODYSSEY" ]
    then
        BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    fi
fi

# Export in PATH if the binary is accessible.
if [ -x "$BCBIO_EXE" ]
then
    export BCBIO_EXE
    unset -v PYTHONHOME PYTHONPATH
    bcbio_bin_dir="$( dirname "$BCBIO_EXE" )"
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    add_to_path_end "$bcbio_bin_dir"
    unset -v bcbio_bin_dir
fi
