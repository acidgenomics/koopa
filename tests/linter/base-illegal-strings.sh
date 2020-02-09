#!/usr/bin/env bash

# """
# Find illegal strings, such as FIXME, TODO, and messed up git merges.
# Updated 2020-02-09.
#
# Use find first, pass to array, and then call grep.
# This is better supported across platforms.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

prefix="${1:-$KOOPA_PREFIX}"

# shellcheck disable=SC2016
illegal_strings=(
    ' path='
    '; do'
    '; then'
    '<  <'
    '<<<<<<<'
    '>>>>>>>'
    'IFS=  '
    '\$path'
    '\bFIXME\b'
    '\bTODO\b'
    '^path='
    'os.system'
)
grep_pattern="$(_koopa_paste0 '|' "${illegal_strings[@]}")"

files=()
while IFS= read -r -d $'\0'
do
    files+=("$REPLY")
done < <( \
    find "$prefix" \
        -mindepth 1 \
        -type f \
        -not -name "$(basename "$0")" \
        -not -name ".pylintrc" \
        -not -path "${KOOPA_PREFIX}/.git/*" \
        -not -path "${KOOPA_PREFIX}/dotfiles/*" \
        -not -path "${KOOPA_PREFIX}/shunit2-*" \
        -print0 \
    | sort -z
)

failures="$( \
    grep -En \
        --binary-files="without-match" \
        "$grep_pattern" \
        "${files[@]}" \
    || echo "" \
)"

name="$(_koopa_basename_sans_ext "$0")"
if [[ -n "$failures" ]]
then
    _koopa_status_fail "$name"
    echo "$failures"
    exit 1
else
    _koopa_status_ok "$name"
    exit 0
fi
