#!/usr/bin/env bash

koopa_jekyll_serve() {
    # """
    # Render Jekyll website.
    # Updated 2023-04-06.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['bundle']="$(koopa_locate_bundle)"
    koopa_assert_is_executable "${app[@]}"
    dict['bundle_prefix']="$(koopa_xdg_data_home)/gem"
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    koopa_alert "Serving Jekyll website in '${dict['prefix']}'."
    (
        koopa_cd "${dict['prefix']}"
        koopa_assert_is_file 'Gemfile'
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll serve
        koopa_rm 'Gemfile.lock'
    )
    return 0
}
