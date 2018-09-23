#!/usr/bin/env bash

# Activate koopa in the current bash shell.
# 2018-09-22

# Check for supported operating system.
# Alternatively can use `$(uname -s)`
# solaris, bsd are not supported.
case "$OSTYPE" in
    darwin* ) os="macOS";; 
     linux* ) os="Linux";;
          * ) echo "Unsupported system: ${OSTYPE}"; exit 1;;
esac

# Load non-interactive shell scripts.
where="${KOOPA_SYSDIR}/activate/non-interactive"
for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort); do
    source "$file"
done
unset -v file where

# Load interactive shell scripts.
if [[ "$-" =~ "i" ]]; then
    where="${KOOPA_SYSDIR}/activate/interactive"
    for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort); do
        source "$file"
    done
    unset -v file where
    # Show the info box when activating on an interactive login shell.
    koopa info
fi
