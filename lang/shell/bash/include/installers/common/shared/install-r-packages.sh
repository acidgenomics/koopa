#!/usr/bin/env bash

main() {
    # """
    # Install R packages.
    # @note Updated 2022-07-07.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
    declare -A dict=(
        [bioc_version]="$(koopa_variable 'bioconductor')"
    )
    "${app[rscript]}" -e " \
        isInstalled <- function(pkgs) { ; \
            basename(pkgs) %in% rownames(utils::installed.packages()); \
        } ; \
        if (isFALSE(isInstalled('AcidDevTools'))) { ; \
            install.packages(pkgs = 'BiocManager'); \
            BiocManager::install(version = '${dict[bioc_version]}'); \
            install.packages(pkgs = 'AcidDevTools'); \
        } ; \
        AcidDevTools::installRecommendedPackages(); \
    "
    return 0
}
