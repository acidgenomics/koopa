#!/usr/bin/env bash

main() {
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2022-08-02.
    #
    # In case of missing files in '/etc/R', such as ldpaths or Makeconf:
    # > sudo apt purge r-base-core
    # > sudo apt install r-base-core
    #
    # For additional cleanup, consider removing '/etc/R', '/usr/lib/R',
    # and '/usr/local/lib/R'.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/README.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [r]='/usr/bin/R'
    )
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
    )
    # These removal steps will mess up existing installation, unless we run
    # 'sudo apt purge r-base-core' first.
    # > koopa_rm --sudo \
    # >     '/etc/R' \
    # >     '/usr/lib/R/etc' \
    # >     '/usr/local/lib/R'
    koopa_debian_apt_add_r_repo "${dict[version]}"
    pkgs=('r-base' 'r-base-dev')
    koopa_debian_apt_install "${pkgs[@]}"
    koopa_assert_is_installed "${app[r]}"
    koopa_configure_r "${app[r]}"
    return 0
}
