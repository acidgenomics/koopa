#!/usr/bin/env bash

# FIXME Rework using dict approach.
koopa:::linux_install_aspera_connect() { # {{{1
    # """
    # Install Aspera Connect.
    # @note Updated 2021-09-15.
    #
    # Use Homebrew Cask to install on macOS instead.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
    # """
    local aspera_user file name platform prefix script script_target url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='ibm-aspera-connect'
    platform='linux'
    file="${name}_${version}_${platform}.tar.gz"
    url="https://d3gcli72yxqn2z.cloudfront.net/connect_latest/v4/bin/${file}"
    koopa::download "$url" "$file"
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

