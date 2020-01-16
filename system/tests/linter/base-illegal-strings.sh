#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Find illegal strings, such as FIXME, TODO, and messed up git merges.
# Updated 2020-01-16.
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
)
grep_pattern="$(_koopa_paste0 '|' "${illegal_strings[@]}")"

array=()
while IFS= read -r -d $'\0'
do
    array+=("$REPLY")
done < <( \
    find "$prefix" \
    -mindepth 1 \
    -type f \
    -not -name "$(basename "$0")" \
    -not -name ".pylintrc" \
    -not -path "${KOOPA_PREFIX}/.git/*" \
    -not -path "${KOOPA_PREFIX}/dotfiles/*" \
    -print0 \
    | sort
)

failures="$( \
    grep -En \
        --binary-files="without-match" \
        "$grep_pattern" \
        "${array[@]}" \
        || echo "" \
)"

name="$(_koopa_basename_sans_ext "$0")"
if [[ -n "$failures" ]]
then
    printf "FAIL | %s\n" "$name"
    echo "$failures"
    exit 1
else
    printf "  OK | %s\n" "$name"
    exit 0
fi
