#!/usr/bin/env bash
set -Eeu -o pipefail

# Recursively run pylint on all Python scripts in a directory.
# Updated 2019-10-07.

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/posix/include/functions.sh"

script_bn="$(_koopa_basename_sans_ext "$0")"

# Skip test if pylint is not installed.
if ! _koopa_is_installed pylint
then
    printf "NOTE | %s\n" "$script_bn"
    printf "     |   pylint missing.\n"
    exit 0
fi

path="${1:-$KOOPA_PREFIX}"

exclude_dirs=(
    "${KOOPA_PREFIX}/cellar"
    "${KOOPA_PREFIX}/conda"
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

# Prepend the '--exclude-dir=' flag.
exclude_dirs=("${exclude_dirs[@]/#/--exclude-dir=}")

# Find scripts by file extension.
ext_files=()
while IFS=  read -r -d $'\0'
do
    ext_files+=("$REPLY")
done < <(find "${KOOPA_PREFIX}/pykoopa" -iname "*.py" -print0)

# This step recursively grep matches files with regular expressions.
# Here we're checking for the shebang, rather than relying on file extension.
shebang_files="$( \
    grep -Elr \
    --binary-files="without-match" \
    "${exclude_dirs[@]}" \
    '^#!/.*\bpython(3)?\b$' \
    "$path" \
)"
mapfile -t shebang_files <<< "$shebang_files"

merge=("${ext_files[@]}" "${shebang_files[@]}")
files="$(printf "%q\n" "${merge[@]}" | sort -u)"
mapfile -t files <<< "$files"

# Note that setting '--jobs=0' flag here enables multicore.
pylint --jobs=0 --score=n "${files[@]}"

printf "  OK | %s\n" "$script_bn"
exit 0
