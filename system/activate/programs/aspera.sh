#!/bin/sh

## Include Aspera Connect binaries in PATH, if defined.
## Updated 2019-06-25.

if [ -z "${ASPERA_EXE:-}" ]
then
    ASPERA_EXE="${HOME}/.aspera/connect/bin/asperaconnect"
fi

## Export in PATH, if accessible.
if [ -x "$ASPERA_EXE" ]
then
    export ASPERA_EXE
    bin_dir="$(dirname "$ASPERA_EXE")"
    _koopa_add_to_path_start "$bin_dir"
    unset -v bin_dir
else
    unset -v ASPERA_EXE
fi

