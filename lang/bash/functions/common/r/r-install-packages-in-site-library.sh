#!/usr/bin/env bash

koopa_r_install_packages_in_site_library() {
    # """
    # Install packages into R site library.
    # @note Updated 2024-05-28.
    # """
    local -A app
    koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    shift 1
    koopa_r_script \
        --r="${app['r']}" \
        'install-packages-in-site-library.R' \
        "$@"
    return 0
}
