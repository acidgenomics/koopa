#!/usr/bin/env bash

# """
# Recursively run shellcheck on all scripts in a directory.
# Updated 2020-02-01.
#
# Use find first, pass to array, and then call grep.
# This is better supported across platforms.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

name="$(_koopa_basename_sans_ext "$0")"

# Skip test if shellcheck is not installed.
# Currently, Travis CI does not have shellcheck installed for macOS.
if ! _koopa_is_installed shellcheck
then
    printf "NOTE | %s\n" "$name"
    printf "     |   shellcheck missing.\n"
    exit 0
fi

prefix="${1:-$KOOPA_PREFIX}"

# Find scripts by shebang.
mapfile -t shebang_files < <( \
    find "$prefix" \
        -mindepth 1 \
        -type f \
        -not -path "${KOOPA_PREFIX}/.git/*" \
        -not -path "${KOOPA_PREFIX}/dotfiles/*" \
        -not -path "${KOOPA_PREFIX}/shunit2-*" \
        -print0 \
    | xargs -0 -I {} \
    grep -El \
        --binary-files="without-match" \
        '^#!/.*\b(ba)?sh\b$' \
        {} \
)

shellcheck -x "${shebang_files[@]}"

_koopa_status_ok "$name"
