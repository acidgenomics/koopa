#!/usr/bin/env bash

# """
# Run lintr on all R scripts.
# Updated 2020-04-13.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

koopa::exit_if_not_installed R
koopa::exit_if_r_package_not_installed lintr

# Find scripts by file extension.
ext="R"
readarray -t r_files <<< "$(koopa::test_find_files_by_ext "$ext")"
# > koopa::info "${#r_files[@]} R files matched by extension."

# Find scripts by shebang.
grep_pattern='^#!/.*\bRscript\b$'
readarray -t rscript_files <<< \
    "$(koopa::test_find_files_by_shebang "$grep_pattern")"
# > koopa::info "${#rscript_files[@]} Rscript files matched by shebang."

# Merge the arrays.
merge=("${r_files[@]}" "${rscript_files[@]}")
files="$(printf "%q\n" "${merge[@]}" | sort -u)"
readarray -t files <<< "$files"

# Include 'Rprofile.site' file.
files+=("${KOOPA_PREFIX}/etc/R/Rprofile.site")

# > koopa::info "Checking ${#files[@]} files."

# Loop across the files and run lintr.
for file in "${files[@]}"
do
    Rscript -e "lintr::lint(file = \"${file}\")"
done

name="$(koopa::basename_sans_ext "$0")"
koopa::status_ok "${name} [${#files[@]}]"
