#!/usr/bin/env bash

# """
# Recursively run pylint on all Python scripts in a directory.
# Updated 2020-02-01.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

name="$(_koopa_basename_sans_ext "$0")"

# Skip test if pylint is not installed.
if ! _koopa_is_installed pylint
then
    printf "NOTE | %s\n" "$name"
    printf "     |   pylint missing.\n"
    exit 0
fi

prefix="${1:-$KOOPA_PREFIX}"

# Find scripts by file extension.
ext_files=()
while IFS= read -r -d $'\0'
do
    ext_files+=("$REPLY")
done < <( \
    find "$prefix" \
        -mindepth 1 \
        -type f \
        -iname "*.py" \
        -not -path "${KOOPA_PREFIX}/.git/*" \
        -not -path "${KOOPA_PREFIX}/dotfiles/*" \
        -not -path "${KOOPA_PREFIX}/shunit2-*" \
        -print0 \
)

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
        '^#!/.*\bpython(3)?\b$' \
        {} \
)

merge=("${ext_files[@]}" "${shebang_files[@]}")
files="$(printf "%q\n" "${merge[@]}" | sort -u)"
mapfile -t files <<< "$files"

# Note that setting '--jobs=0' flag here enables multicore.
python3 -m pylint --jobs=0 --score=n "${files[@]}"

_koopa_status_ok "$name"
