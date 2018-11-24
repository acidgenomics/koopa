#!/usr/bin/env bash

# Activate koopa in the current bash shell.

# Check for supported operating system.
# Alternatively can use `$(uname -s)`
# solaris, bsd are not supported.
case "$OSTYPE" in
    darwin* ) os="macOS";;
     linux* ) os="Linux";;
          * ) echo "Unsupported system: ${OSTYPE}"; exit 1;;
esac

# 1. Always load non-interactive shell scripts.
where="${KOOPA_SYS_DIR}/activate/01_non-interactive"
for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort); do
    source "$file"
done
unset -v file where

# 2. If necessary, load interactive shell scripts.
if [[ "$-" =~ "i" ]]; then
    where="${KOOPA_SYS_DIR}/activate/02_interactive"
    for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort); do
        source "$file"
    done
    unset -v file where
fi
