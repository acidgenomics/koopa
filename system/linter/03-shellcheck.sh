#!/usr/bin/env bash
set -Eeu -o pipefail

# Recursively run shellcheck on all scripts in a directory.
# Updated 2019-07-28.

path="${1:-$KOOPA_HOME}"

exclude_dirs=(
    "${KOOPA_HOME}/cellar"
    "${KOOPA_HOME}/conda"
    "${KOOPA_HOME}/system/activate/shell/zsh/fpath"
    "${KOOPA_HOME}/system/config/dotfiles"
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

# This step recursively grep matches files with regular expressions.
# Here we're checking for the shebang, rather than relying on file extension.

grep -Elr \
    --binary-files="without-match" \
    "${exclude_dirs[@]}" \
    '^#!/.*\b(ba)?sh\b$' \
    "$path" | \
    xargs -I {} shellcheck -x {}

printf "  OK | %s\n" "$(basename "$0")"
exit 0
