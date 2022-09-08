#!/usr/bin/env bash

koopa_install_r_packages() {
    # """
    # Install R packages.
    # @note Updated 2022-09-08.
    # """
    local app
    koopa_assert_has_args_le "$#" 1
    declare -A app
    app['r']="${1:-}"
    if [[ -z "${app['r']}" ]] && koopa_is_macos
    then
        app['r']="$(koopa_macos_r_prefix)/bin/R"
    fi
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    koopa_configure_r "${app['r']}"
    "${app['rscript']}" -e " \
        if (!requireNamespace('AcidDevTools', quietly = TRUE)) { ; \
            install.packages('AcidDevTools') ; \
        } ; \
        AcidDevTools::installRecommendedPackages(); \
    "
    return 0
}
