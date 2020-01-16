#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Find lines containing more than 80 characters.
# Updated 2020-01-16.
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
        -print0 \
    | sort
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
    printf "FAIL | %s\n" "$name"
    echo "$failures"
    exit 1
else
    printf "  OK | %s\n" "$name"
    exit 0
fi
