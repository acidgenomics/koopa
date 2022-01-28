#!/usr/bin/env bash

koopa:::debian_install_r_cran_binary() { # {{{1
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2022-01-28.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/README.html
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [r]='/usr/bin/R'
    )
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
    )
    koopa::rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc' \
        '/usr/local/lib/R'
    koopa::debian_apt_add_r_repo "${dict[version]}"
    pkgs=('r-base' 'r-base-dev')
    koopa::debian_apt_install "${pkgs[@]}"
    koopa::configure_r "${app[r]}"
    return 0
}
