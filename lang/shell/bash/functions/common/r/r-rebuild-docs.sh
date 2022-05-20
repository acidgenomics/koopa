#!/usr/bin/env bash

koopa_r_rebuild_docs() {
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2022-04-08.
    #
    # 1. Ensure HTML package index is writable.
    # 2. Touch an empty 'R.css' file to eliminate additional package warnings.
    #    Currently we're seeing this inside Fedora Docker images.
    #
    # @seealso
    # HTML package index configuration:
    # https://stat.ethz.ch/R-manual/R-devel/library/utils/html/
    #     make.packages.html.html
    # """
    local app doc_dir html_dir pkg_index rscript_args
    declare -A app=(
        [r]="${1:-}"
    )
    declare -A dict
    [[ -z "${app[r]:-}" ]] && app[r]="$(koopa_locate_r)"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    koopa_is_koopa_app "${app[rscript]}" || return 0
    rscript_args=('--vanilla')
    koopa_alert 'Updating HTML package index.'
    dict[doc_dir]="$( \
        "${app[rscript]}" "${rscript_args[@]}" -e 'cat(R.home("doc"))' \
    )"
    dict[html_dir]="${dict[doc_dir]}/html"
    dict[pkg_index]="${dict[html_dir]}/packages.html"
    dict[r_css]="${dict[html_dir]}/R.css"
    if [[ ! -d "${dict[html_dir]}" ]]
    then
        koopa_mkdir "${dict[html_dir]}"
    fi
    if [[ ! -f "${dict[pkg_index]}" ]]
    then
        koopa_touch "${dict[pkg_index]}"
    fi
    if [[ ! -f "${dict[r_css]}" ]]
    then
        koopa_touch "${dict[r_css]}"
    fi
    koopa_sys_set_permissions "${dict[pkg_index]}"
    "${app[rscript]}" "${rscript_args[@]}" -e 'utils::make.packages.html()'
    return 0
}
