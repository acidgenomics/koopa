#!/usr/bin/env bash

_koopa_jekyll_serve() {
    # """
    # Render Jekyll website.
    # Updated 2023-04-06.
    # """
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    app['bundle']="$(_koopa_locate_bundle)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bundle_prefix']="$(_koopa_xdg_data_home)/gem"
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="${PWD:?}"
    dict['prefix']="$(_koopa_realpath "${dict['prefix']}")"
    _koopa_alert "Serving Jekyll website in '${dict['prefix']}'."
    (
        _koopa_cd "${dict['prefix']}"
        _koopa_assert_is_file 'Gemfile'
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && _koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll serve
        _koopa_rm 'Gemfile.lock'
    )
    return 0
}
