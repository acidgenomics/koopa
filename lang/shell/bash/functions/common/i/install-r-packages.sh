#!/usr/bin/env bash

# FIXME Move this to separate install script.
# FIXME Rework Bioconductor version pinnings here. Define based on R version.

koopa_install_r_packages() {
    # """
    # Install R packages.
    # @note Updated 2022-08-23.
    #
    # @seealso
    # - https://bioconductor.org/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['r']="$(koopa_locate_r)"
        ['rscript']="$(koopa_locate_rscript)"
    )
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    koopa_configure_r "${app['r']}"
    declare -A dict=(
        # FIXME Rework this approach.
        ['bioc_version']='3.15'
    )
    "${app['rscript']}" -e " \
        isInstalled <- function(pkgs) { ; \
            basename(pkgs) %in% rownames(utils::installed.packages()); \
        } ; \
        if (isFALSE(isInstalled('AcidDevTools'))) { ; \
            install.packages(pkgs = 'BiocManager'); \
            BiocManager::install(version = '${dict['bioc_version']}'); \
            install.packages(pkgs = 'AcidDevTools'); \
        } ; \
        AcidDevTools::installRecommendedPackages(); \
    "
    return 0
}
