#!/usr/bin/env bash
set -Eeu -o pipefail

# Check that all scripts support '--help' flag.
# Updated 2019-11-05.

KOOPA_HOME="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../.." \
    >/dev/null 2>&1 && pwd -P)"
export KOOPA_HOME

# Put all 'bin/' and/or 'sbin/' dirs into an array and loop.
dirs=()
while IFS=  read -r -d $'\0'
do
    dirs+=("$REPLY")
done < <( \
    find "$KOOPA_HOME" \
        -mindepth 1 \
        -type d \
        \( -name "bin" -o -name "sbin" \) \
        -not -path "*/cellar/*" \
        -not -path "*/dotfiles/*" \
        -print0 \
    )

for dir in "${dirs[@]}"
do
    files=()
    while IFS=  read -r -d $'\0'
    do
        files+=("$REPLY")
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f -print0)
    for file in "${files[@]}"
    do
        echo "$file"
        nice "$file" --help > /dev/null
    done
done
