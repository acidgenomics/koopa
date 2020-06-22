#!/usr/bin/env bash

# """
# Run lintr on all R scripts.
# Updated 2020-04-13.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

_koopa_exit_if_not_installed R
_koopa_exit_if_r_package_not_installed lintr

# Find scripts by file extension.
ext="R"
readarray -t r_files <<< "$(_koopa_test_find_files_by_ext "$ext")"
# > _koopa_info "${#r_files[@]} R files matched by extension."

# Find scripts by shebang.
grep_pattern='^#!/.*\bRscript\b$'
readarray -t rscript_files <<< \
    "$(_koopa_test_find_files_by_shebang "$grep_pattern")"
# > _koopa_info "${#rscript_files[@]} Rscript files matched by shebang."

# Merge the arrays.
merge=("${r_files[@]}" "${rscript_files[@]}")
files="$(printf "%q\n" "${merge[@]}" | sort -u)"
readarray -t files <<< "$files"

# Include 'Rprofile.site' file.
files+=("${KOOPA_PREFIX}/etc/R/Rprofile.site")

# > _koopa_info "Checking ${#files[@]} files."

# Loop across the files and run lintr.
for file in "${files[@]}"
do
    Rscript -e "lintr::lint(file = \"${file}\")"
done

name="$(_koopa_basename_sans_ext "$0")"
_koopa_status_ok "${name} [${#files[@]}]"
