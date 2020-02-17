#!/usr/bin/env bash

# """
# Find illegal strings, such as FIXME, TODO, and messed up git merges.
# Updated 2020-02-16.
#
# Use find first, pass to array, and then call grep.
# This is better supported across platforms.
# """

# shellcheck source=/dev/null
source "$(koopa header bash)"

koopa_prefix="$(_koopa_prefix)"
prefix="${1:-${koopa_prefix}}"

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
        -not -path "${koopa_prefix}/.git/*" \
        -not -path "${koopa_prefix}/cellar/*" \
        -not -path "${koopa_prefix}/coverage/*" \
        -not -path "${koopa_prefix}/dotfiles/*" \
        -not -path "${koopa_prefix}/opt/*" \
        -print0 \
    | sort -z
)

failures=()
for file in "${files[@]}"
do
    x="$(
        grep -En \
            --binary-files="without-match" \
            "$grep_pattern" \
            "$file" \
        || true \
    )"
    [[ -n "$x" ]] && failures+=("$x")
done

name="$(_koopa_basename_sans_ext "$0")"

if _koopa_is_array_non_empty "${failures[@]}"
then
    _koopa_status_fail "$name"
    echo "${failures[@]}"
    exit 1
else
    _koopa_status_ok "$name"
    exit 0
fi
