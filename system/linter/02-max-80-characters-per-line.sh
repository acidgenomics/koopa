#!/usr/bin/env bash
set -Eeu -o pipefail

# Find lines containing more than 80 characters.
# Updated 2019-07-28.

# Returns with `true` or `false` exit codes.

path="${1:-$KOOPA_HOME}"
dotfiles_dir="${KOOPA_HOME}/system/config/dotfiles"

exclude_dirs=(
    "${KOOPA_HOME}/cellar"
    "${KOOPA_HOME}/conda"
    "${KOOPA_HOME}/system/activate/shell/zsh/fpath"
    "${dotfiles_dir}/doom.d"
    "${dotfiles_dir}/dracula"
    "${dotfiles_dir}/os/darwin/terminal"
    "${dotfiles_dir}/vim"
    ".git"
)

# Note that full path exclusion doesn't work on Travis CI.
if [[ -n "${TRAVIS:-}" ]]
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
        --exclude="*.md" \
        "${exclude_dirs[@]}" \
        "^[^\n]{81}" \
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
