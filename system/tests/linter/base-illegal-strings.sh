#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Find illegal strings, such as FIXME, TODO, and messed up git merges.
# Updated 2020-01-16.
#
# @return 'true' or 'false' exit codes.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

path="${1:-$KOOPA_PREFIX}"

exclude_dirs=(
    "${KOOPA_PREFIX}/dotfiles"
    "${KOOPA_PREFIX}/shell/zsh/functions"
    ".git"
)
exclude_files=(
    "$(basename "$0")"
    ".pylintrc"
)

# Full path exclusion seems to only work on macOS.
if ! _koopa_is_macos
then
    for i in "${!exclude_dirs[@]}"
    do
        exclude_dirs[$i]="$(basename "${exclude_dirs[$i]}")"
    done
    for i in "${!exclude_files[@]}"
    do
        exclude_files[$i]="$(basename "${exclude_files[$i]}")"
    done
fi

# Prepend the '--exclude=' flag.
exclude_files=("${exclude_files[@]/#/--exclude=}")

# Prepend the '--exclude-dir=' flag.
exclude_dirs=("${exclude_dirs[@]/#/--exclude-dir=}")

illegal_strings=(
    '<<<<<<<'
    '>>>>>>>'
    '\bFIXME\b'
    '\bHEAD\b'
    '\bTODO\b'
)
grep_pattern="$(_koopa_paste0 '|' "${illegal_strings[@]}")"
hits="$( \
    grep -Elr \
        --binary-files="without-match" \
        "${exclude_files[@]}" \
        "${exclude_dirs[@]}" \
        "$grep_pattern" \
        "$path" | \
        sort || echo "" \
)"

name="$(_koopa_basename_sans_ext "$0")"
if [[ -n "$hits" ]]
then
    printf "FAIL | %s\n" "$name"
    echo "$hits"
    exit 1
else
    printf "  OK | %s\n" "$name"
    exit 0
fi
