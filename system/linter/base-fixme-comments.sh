#!/usr/bin/env bash
set -Eeu -o pipefail

# Find FIXME and TODO comments.
# Updated 2019-10-07.

# Returns with 'true' or 'false' exit codes.

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
exclude_files=(
    "$(basename "$0")"
    ".pylintrc"
)

# Full path exclusion seems to only work on macOS.
if ! _acid_is_darwin
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

hits="$( \
    grep -Elr \
        --binary-files="without-match" \
        "${exclude_files[@]}" \
        "${exclude_dirs[@]}" \
        "\b(FIXME|TODO)\b" \
        "$path" | \
        sort || echo "" \
)"

name="$(_acid_basename_sans_ext "$0")"
if [[ -n "$hits" ]]
then
    printf "FAIL | %s\n" "$name"
    echo "$hits"
    exit 1
else
    printf "  OK | %s\n" "$name"
    exit 0
fi
