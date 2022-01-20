#!/usr/bin/env bash

koopa::r_rebuild_docs() { # {{{1
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2022-01-20.
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
        [sudo]="$(koopa::locate_sudo)"
        [touch]="$(koopa::locate_touch)"
    )
    declare -A dict
    [[ -z "${app[r]:-}" ]] && app[r]="$(koopa::locate_r)"
    app[rscript]="${app[r]}script"
    koopa::assert_is_installed "${app[rscript]}"
    rscript_args=('--vanilla')
    koopa::alert 'Updating HTML package index.'
    dict[doc_dir]="$( \
        "${app[rscript]}" "${rscript_args[@]}" -e 'cat(R.home("doc"))' \
    )"
    dict[html_dir]="${dict[doc_dir]}/html"
    dict[pkg_index]="${dict[html_dir]}/packages.html"
    dict[r_css]="${dict[html_dir]}/R.css"
    if [[ ! -d "${dict[html_dir]}" ]]
    then
        koopa::mkdir --sudo "${dict[html_dir]}"
    fi
    if [[ ! -f "${dict[pkg_index]}" ]]
    then
        koopa::assert_is_admin
        "${app[sudo]}" "${app[touch]}" "${dict[pkg_index]}"
    fi
    if [[ ! -f "${dict[r_css]}" ]]
    then
        koopa::assert_is_admin
        "${app[sudo]}" "${app[touch]}" "${dict[r_css]}"
    fi
    koopa::sys_set_permissions "${dict[pkg_index]}"
    "${app[rscript]}" "${rscript_args[@]}" -e 'utils::make.packages.html()'
    return 0
}
