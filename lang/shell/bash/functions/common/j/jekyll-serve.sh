#!/usr/bin/env bash

koopa_jekyll_serve() {
    # """
    # Render Jekyll website.
    # Updated 2023-02-17.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app
    app['bundle']="$(koopa_locate_bundle)"
    [[ -x "${app['bundle']}" ]] || exit 1
    declare -A dict=(
        ['bundle_prefix']="$(koopa_xdg_data_home)/gem"
        ['prefix']="${1:-}"
    )
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
