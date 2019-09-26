#!/usr/bin/env bash
set -Eeu -o pipefail

# Find FIXME and TODO comments.
# Updated 2019-09-23.

# Returns with `true` or `false` exit codes.

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/posix/include/functions.sh"

path="${1:-$KOOPA_HOME}"

exclude_dirs=(
    "${KOOPA_HOME}/cellar"
    "${KOOPA_HOME}/conda"
    "${KOOPA_HOME}/dotfiles"
    "${KOOPA_HOME}/shell/zsh/functions"
    ".git"
)

# Full path exclusion seems to only work on macOS.
if ! _koopa_is_darwin
then
    for i in "${!exclude_dirs[@]}"
    do
        exclude_dirs[$i]="$(basename "${exclude_dirs[$i]}")"
    done
fi

# Prepend the `--exclude-dir=` flag.
exclude_dirs=("${exclude_dirs[@]/#/--exclude-dir=}")

hits="$( \
    grep -Elr \
        --binary-files="without-match" \
        --exclude="$(basename "$0")" \
        "${exclude_dirs[@]}" \
        "\b(FIXME|TODO)\b" \
        "$path" | \
        sort || echo "" \
)"

if [[ -n "$hits" ]]
then
    printf "FAIL | %s\n" "$(basename "$0")"
    echo "$hits"
    exit 1
else
    printf "  OK | %s\n" "$(basename "$0")"
    exit 0
fi
