#!/usr/bin/env bash

koopa_r_rebuild_docs() {
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2023-04-04.
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
    declare -A app dict
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    rscript_args=('--vanilla')
    dict['doc_dir']="$( \
        "${app['rscript']}" "${rscript_args[@]}" -e 'cat(R.home("doc"))' \
    )"
    koopa_assert_is_dir "${dict['doc_dir']}"
    koopa_alert_info "Updating documentation in '${dict['doc_dir']}'."
    case "${dict['system']}" in
        '1')
            app['sudo']="$(koopa_locate_sudo)"
            [[ -x "${app['sudo']}" ]] || return 1
            "${app['sudo']}" "${app['rscript']}" \
                "${rscript_args[@]}" \
                -e 'utils::make.packages.html()'
            ;;
        '0')
            dict['html_dir']="${dict['doc_dir']}/html"
            dict['pkg_index']="${dict['html_dir']}/packages.html"
            dict['r_css']="${dict['html_dir']}/R.css"
            if [[ ! -d "${dict['html_dir']}" ]]
            then
                koopa_mkdir "${dict['html_dir']}"
            fi
            if [[ ! -f "${dict['pkg_index']}" ]]
            then
                koopa_touch "${dict['pkg_index']}"
            fi
            if [[ ! -f "${dict['r_css']}" ]]
            then
                koopa_touch "${dict['r_css']}"
            fi
            "${app['rscript']}" \
                "${rscript_args[@]}" \
                -e 'utils::make.packages.html()'
            ;;
    esac
    return 0
}
