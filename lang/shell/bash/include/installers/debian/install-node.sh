#!/usr/bin/env bash

debian_install_node() { # {{{1
    # """
    # Install Node.js for Debian using NodeSource.
    # @note Updated 2022-01-28.
    #
    # This will configure apt at '/etc/apt/sources.list.d/nodesource.list'.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[url]="https://deb.nodesource.com/setup_${dict[maj_ver]}.x"
    dict[file]='setup.sh'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "${app[sudo]}" "./${dict[file]}"
    koopa_debian_apt_install 'nodejs'
    return 0
}
