#!/usr/bin/env bash
set -Eeu -o pipefail

# Find lines containing more than 80 characters.
# Updated 2020-01-16.

# Returns with 'true' or 'false' exit codes.

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/posix/include/functions.sh"

path="${1:-$KOOPA_PREFIX}"

exclude_dirs=(
    "${KOOPA_PREFIX}/dotfiles"
    "${KOOPA_PREFIX}/shell/zsh/functions"
    ".git"
)

# Full path exclusion seems to only work on macOS.
if ! _koopa_is_macos
then
    for i in "${!exclude_dirs[@]}"
    do
        exclude_dirs[$i]="$(basename "${exclude_dirs[$i]}")"
    done
fi

# Prepend the '--exclude-dir' flag.
exclude_dirs=("${exclude_dirs[@]/#/--exclude-dir=}")

hits="$( \
    grep -Elr \
        --binary-files="without-match" \
        --exclude="*.md" \
        "${exclude_dirs[@]}" \
        "^[^\n]{81}" \
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
