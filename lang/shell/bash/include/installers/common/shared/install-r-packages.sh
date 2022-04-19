#!/usr/bin/env bash

# FIXME Configure a pinned version of Bioconductor here.

main() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2022-04-15.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
    "${app[rscript]}" -e " \
        install.packages(pkgs = 'AcidDevTools', dependencies = NA); \
        AcidDevTools::installRecommendedPackages(); \
        install.packages(pkgs = 'koopa', dependencies = TRUE); \
    "
    return 0
}
