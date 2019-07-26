#!/bin/sh

## Include bcbio toolkit binaries in PATH, if defined.
## Updated 2019-06-25.

## Attempt to locate bcbio installation automatically on supported platforms.

if [ -z "${BCBIO_EXE:-}" ]
then
    host="$(koopa host-type)"
    if [ "$host" = "harvard-o2" ]
    then
        BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [ "$host" = "harvard-odyssey" ]
    then
        BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    else
        BCBIO_EXE=
    fi
    unset -v host
fi

## Export in PATH, if accessible.
if [ -x "$BCBIO_EXE" ]
then
    export BCBIO_EXE
    unset -v PYTHONHOME PYTHONPATH
    bin_dir="$(dirname "$BCBIO_EXE")"
    ## Exporting at the end of PATH so we don't mask gcc or R.
    ## This is particularly important to avoid unexpected compilation issues
    ## due to compilers in conda masking the system versions.
    _koopa_force_add_to_path_end "$bin_dir"
    unset -v bin_dir
else
    unset -v BCBIO_EXE
fi
