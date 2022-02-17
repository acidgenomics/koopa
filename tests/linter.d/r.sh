#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../lang/shell/bash/include/header.sh"

main() { # {{{1
    # """
    # R script checks.
    # Updated 2020-07-07.
    # """
    local files merge r_files rscript_files
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'R'
    koopa::assert_is_r_package_installed 'lintr'
    # Find scripts by file extension.
    readarray -t r_files <<< "$(koopa::test_find_files_by_ext '.R')"
    # Find scripts by shebang.
    readarray -t rscript_files <<< \
        "$(koopa::test_find_files_by_shebang '^#!/.*\bRscript\b$')"
    # Merge the arrays.
    merge=("${r_files[@]}" "${rscript_files[@]}")
    files="$(printf '%q\n' "${merge[@]}" | sort -u)"
    readarray -t files <<< "$files"
    # Include 'Rprofile.site' file.
    files+=("${KOOPA_PREFIX:?}/etc/R/Rprofile.site")
    test_lintr "${files[@]}"
    return 0
}

test_lintr() { # {{{1
    local app file
    koopa::assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa::locate_rscript)"
    )
    for file in "$@"
    do
        # Handle empty string edge case.
        [ -f "$file" ] || continue
        "${app[rscript]}" -e "lintr::lint(file = '${file}')"
    done
    koopa::status_ok "r-linter [${#}]"
    return 0
}

main "$@"
