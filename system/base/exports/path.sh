#!/bin/sh
# shellcheck disable=SC2236

# Improve PATH consistency.
# Note that here we're making sure local binaries are included.
# `sbin` = superuser binaries.
# https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

# Inspect `/etc/profile` if system PATH is misconfigured.

# FIXME Need to check if already in PATH, instead of forcing re-export.

add_to_path_end "${HOME}/local/bin"
add_to_path_end "${HOME}/.local/bin"
add_to_path_end "/usr/local/sbin"
add_to_path_end "/usr/local/bin"
add_to_path_end "/usr/sbin"
add_to_path_end "/usr/bin"
add_to_path_end "/sbin"
add_to_path_end "/bin"

add_to_path_start "$KOOPA_BIN_DIR"

if [ ! -z "$AZURE" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/osname/azure"
elif [ ! -z "$MACOS" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/osname/darwin"
elif [ ! -z "$HARVARD_O2" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/hostname/harvard-o2"
elif [ ! -z "$HARVARD_ODYSSEY" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/hostname/harvard-odyssey"
fi
