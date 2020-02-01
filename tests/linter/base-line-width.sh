#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Find lines containing more than 80 characters.
# Updated 2020-02-01.
#
# Use find first, pass to array, and then call grep.
# This is better supported across platforms.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/posix/include/functions.sh"

prefix="${1:-$KOOPA_PREFIX}"

grep_pattern="^[^\n]{81}"

files=()
while IFS= read -r -d $'\0'
do
    files+=("$REPLY")
done < <( \
    find "$prefix" \
        -mindepth 1 \
        -type f \
        -not -name "*.md" \
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
