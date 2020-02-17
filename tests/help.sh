#!/usr/bin/env bash

# """
# Check that all scripts support '--help' flag.
# Updated 2020-02-01.
# """

KOOPA_PREFIX="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.." \
    >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

_koopa_h1 "Running manual file '--help' flag checks."

# man dirs  {{{1
# ==============================================================================

# Put all 'man/' dirs into an array and loop.
# Pipe GNU find into array.
man_dirs=()
while IFS= read -r -d $'\0'
do
    man_dirs+=("$REPLY")
done < <( \
    find "$KOOPA_PREFIX" \
        -mindepth 1 \
        -type d \
        -name "man" \
        -not -path "${KOOPA_PREFIX}/.git/*" \
        -not -path "${KOOPA_PREFIX}/dotfiles/*" \
        -not -path "${KOOPA_PREFIX}/shunit2-*" \
        -print0 \
    | sort -z \
)

for dir in "${man_dirs[@]}"
do
    _koopa_add_to_manpath_start "$dir"
done

# man file formatting  {{{1
# ==============================================================================

_koopa_h2 "Checking troff man file formatting."

for dir in "${man_dirs[@]}"
do
    files=()
    while IFS= read -r -d $'\0'
    do
        files+=("$REPLY")
    done < <( \
        find "$dir" \
            -mindepth 2 \
            -maxdepth 2 \
            -type f \
            -print0 \
        | sort -z \
    )
    for file in "${files[@]}"
    do
        _koopa_info "$file"
        head -n 1 "$file" \
            | grep -Eq "^\.TH " \
            || _koopa_stop "Invalid man file: '${file}'"
    done
done

exit 0

# '--help' flag support  {{{1
# ==============================================================================

_koopa_h2 "Running exported script '--help' flag checks."

# Put all 'bin/' and/or 'sbin/' dirs into an array and loop.
bin_dirs=()
while IFS= read -r -d $'\0'
do
    bin_dirs+=("$REPLY")
done < <( \
    find "$KOOPA_PREFIX" \
        -mindepth 1 \
        -type d \
        \( -name "bin" -o -name "sbin" \) \
        -not -path "*/cellar/*" \
        -not -path "*/dotfiles/*" \
        -not -path "${KOOPA_PREFIX}/shunit2-*" \
        -print0 \
    | sort -z \
)

for dir in "${bin_dirs[@]}"
do
    files=()
    while IFS= read -r -d $'\0'
    do
        files+=("$REPLY")
    done < <( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -print0 \
        | sort -z \
    )
    for file in "${files[@]}"
    do
        _koopa_info "$file"
        "$file" --help > /dev/null
    done
done
