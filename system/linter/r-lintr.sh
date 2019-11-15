#!/usr/bin/env bash
set -Eeu -o pipefail

# Recursively run lintr on all R scripts in a directory.
# Updated 2019-10-07.

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/posix/include/functions.sh"

script_bn="$(_koopa_basename_sans_ext "$0")"

path="${1:-$KOOPA_PREFIX}"

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

# Prepend the '--exclude-dir=' flag.
exclude_dirs=("${exclude_dirs[@]/#/--exclude-dir=}")

# Find scripts by file extension.
ext_files=()
while IFS=  read -r -d $'\0'
do
    ext_files+=("$REPLY")
done < <(find "${KOOPA_HOME}/system" -iname "*.R" -print0)

# This step recursively grep matches files with regular expressions.
# Here we're checking for the shebang, rather than relying on file extension.
shebang_files="$( \
    grep -Elr \
    --binary-files="without-match" \
    "${exclude_dirs[@]}" \
    '^#!/.*\bRscript\b$' \
    "$path" \
)"
mapfile -t shebang_files <<< "$shebang_files"

merge=("${ext_files[@]}" "${shebang_files[@]}")
files="$(printf "%q\n" "${merge[@]}" | sort -u)"
mapfile -t files <<< "$files"

for file in "${files[@]}"
do
    Rscript -e "lintr::lint(file = \"${file}\")"
done

printf "  OK | %s\n" "$script_bn"
exit 0
