#!/usr/bin/env bash

koopa::linux_install_aspera_connect() { # {{{1
    koopa::linux_install_app \
        --name='aspera-connect' \
        --name-fancy='Aspera Connect' \
        "$@"
}

koopa:::linux_install_aspera_connect() { # {{{1
    # """
    # Install Aspera Connect.
    # @note Updated 2021-05-05.
    #
    # Use Homebrew Cask to install on macOS instead.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
    # """
    local file name platform prefix script url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='ibm-aspera-connect'
    platform='linux'
    file="${name}-${version}-${platform}-g2.12-64.tar.gz"
    url="https://d3gcli72yxqn2z.cloudfront.net/connect_latest/v4/bin/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    script="${file//.tar.gz/.sh}"
    "./${script}"
    # Script install target is currently hard-coded in IBM's install script.
    aspera_user="${HOME}/.aspera"
    script_target="${aspera_user}/connect"
    koopa::assert_is_dir "$script_target"
    if [[ "$prefix" != "$script_target" ]]
    then
        koopa::cp "$script_target" "$prefix"
        koopa::rm "$script_target" "$aspera_user"
    fi
    koopa::assert_is_file "${prefix}/bin/ascp"
    return 0
}

