#!/usr/bin/env bash

debian_install_r_cran_binary() { # {{{1
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2022-01-28.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/README.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [r]='/usr/bin/R'
    )
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc' \
        '/usr/local/lib/R'
    koopa_debian_apt_add_r_repo "${dict[version]}"
    pkgs=('r-base' 'r-base-dev')
    koopa_debian_apt_install "${pkgs[@]}"
    koopa_configure_r "${app[r]}"
    return 0
}
