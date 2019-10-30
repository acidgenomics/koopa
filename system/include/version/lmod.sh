#!/bin/sh

# > module --version 2>&1 \
# >     | grep -Eo "Version [.0-9]+" \
# >     | cut -d ' ' -f 2

echo "${LMOD_VERSION:-}"
