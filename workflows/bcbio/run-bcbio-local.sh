#!/bin/sh

## Assuming a local run on multi-core VM.
## Use n - 2 cores.
bcbio_nextgen_py ../config/bcbio.yaml -t local -n $((CPU_COUNT-2))
