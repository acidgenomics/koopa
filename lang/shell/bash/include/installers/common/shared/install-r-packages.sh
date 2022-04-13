#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2022-04-13.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
    "${app[rscript]}" -e " \
        install.packages(pkgs = 'AcidDevTools'); \
        AcidDevTools::installRecommendedPackages(); \
        install.packages(pkgs = 'koopa', dependencies = TRUE); \
    "
    return 0
}
