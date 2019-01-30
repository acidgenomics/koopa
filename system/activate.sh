#!/bin/sh
# shellcheck disable=SC2236

# Activate koopa in the current shell.

# SC2236: zsh doesn't handle `-n` flag in place of `! -z` correctly in POSIX
# mode using `[` instead of `[[`.

# POSIX sh tricks
# http://www.etalabs.net/sh_tricks.html



quiet_which() {
    command -v "$1" >/dev/null 2>&1
}

add_to_path_start() {
    [ -d "$1" ] || return
    export PATH="$1:$PATH"
}

add_to_path_end() {
    [ -d "$1" ] || return
    export PATH="$PATH:$1"
}



. "${KOOPA_SYSTEM_DIR}/activate/ostype.sh"
. "${KOOPA_SYSTEM_DIR}/activate/bash_version.sh"
. "${KOOPA_SYSTEM_DIR}/activate/python_version.sh"



# Export platform-agnostic binaries.
# These essentially are functions that we're exporting to PATH.
add_to_path_start "$KOOPA_BIN_DIR"

# Export additional OS-specific binaries.
if [ ! -z "$MACOS" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/macos"
fi



. "${KOOPA_SYSTEM_DIR}/activate/exports.sh"
. "${KOOPA_SYSTEM_DIR}/activate/hostname.sh"
. "${KOOPA_SYSTEM_DIR}/activate/genomes.sh"
. "${KOOPA_SYSTEM_DIR}/activate/cpucount.sh"

. "${KOOPA_SYSTEM_DIR}/activate/user_bin.sh"
. "${KOOPA_SYSTEM_DIR}/activate/bcbio.sh"
. "${KOOPA_SYSTEM_DIR}/activate/conda.sh"

. "${KOOPA_SYSTEM_DIR}/activate/ssh_key.sh"
