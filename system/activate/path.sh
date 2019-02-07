#!/bin/sh
# shellcheck disable=SC2236

# Improve PATH consistency.
# Note that here we're making sure local binaries are included.
# `sbin` = superuser binaries.
# https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

add_to_path_end "${HOME}/local"
add_to_path_end "${HOME}/.local"
add_to_path_end "/usr/local/sbin"
add_to_path_end "/usr/local/bin"
add_to_path_end "/usr/sbin"
add_to_path_end "/usr/bin"
add_to_path_end "/sbin"
add_to_path_end "/bin"

add_to_path_start "$KOOPA_BIN_DIR"

if [ ! -z "$MACOS" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/darwin"
fi
