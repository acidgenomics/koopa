#!/usr/bin/env bash

main() {
    # """
    # Install R packages.
    # @note Updated 2022-04-19.
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
        install.packages(pkgs = 'BiocManager', dependencies = NA); \
        BiocManager::install(version = '${dict[bioc_version]}'); \
        install.packages(pkgs = 'AcidDevTools', dependencies = NA); \
        AcidDevTools::installRecommendedPackages(); \
        install.packages(pkgs = 'koopa', dependencies = TRUE); \
    "
    return 0
}
