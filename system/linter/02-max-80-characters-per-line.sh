#!/usr/bin/env bash
set -Eeu -o pipefail

# Find lines containing more than 80 characters.
# Updated 2019-07-27.

# Returns with `true` or `false` exit codes.

path="${1:-$KOOPA_HOME}"
dotfiles_dir="${KOOPA_HOME}/system/config/dotfiles"

hits="$( \
    grep -Er \
        --binary-files="without-match" \
        --exclude="*.md" \
        --exclude-dir=".git" \
        --exclude-dir="${dotfiles_dir}/doom.d" \
        --exclude-dir="${dotfiles_dir}/dracula" \
        --exclude-dir="${dotfiles_dir}/os/darwin/terminal" \
        --exclude-dir="${dotfiles_dir}/vim" \
        --exclude-dir="${KOOPA_HOME}/cellar" \
        --exclude-dir="${KOOPA_HOME}/conda" \
        --exclude-dir="${KOOPA_HOME}/system/activate/shell/zsh/fpath" \
        "^[^\n]{81}" \
        "$path" | \
        sort || echo "" \
)"

if [[ -n "$hits" ]]
then
    printf "Lines exceeding 80 characters detected.\n"
    echo "$hits"
    exit 1
else
    exit 0
fi
