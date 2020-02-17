#!/usr/bin/env bash

# """
# Find lines containing more than 80 characters.
# Updated 2020-02-16.
#
# Use find first, pass to array, and then call grep.
# This is better supported across platforms.
# """

# shellcheck source=/dev/null
source "$(koopa header bash)"

koopa_prefix="$(_koopa_prefix)"
prefix="${1:-${koopa_prefix}}"

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
