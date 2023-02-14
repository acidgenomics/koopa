#!/usr/bin/env bash

koopa_install_r_koopa() {
    # """
    # Install koopa R package.
    # @note Updated 2023-02-13.
    # """
    local app
    koopa_assert_has_args_le "$#" 1
    declare -A app
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    "${app['rscript']}" -e " \
        options(
            error = quote(quit(status = 1L)),
            warn = 1L
        ); \
        if (!requireNamespace('BiocManager', quietly = TRUE)) { ; \
            install.packages('BiocManager'); \
        } ; \
        install.packages(
            pkgs = 'koopa',
            repos = c(
                'https://r.acidgenomics.com',
                BiocManager::repositories()
            ),
            dependencies = TRUE
        ); \
    "
    return 0
}
