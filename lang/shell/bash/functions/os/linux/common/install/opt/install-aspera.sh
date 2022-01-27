#!/usr/bin/env bash

koopa:::linux_install_aspera_connect() { # {{{1
    # """
    # Install Aspera Connect.
    # @note Updated 2022-01-26.
    #
    # Use Homebrew Cask to install on macOS instead.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name]='ibm-aspera-connect'
        [platform]='linux'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}_${dict[version]}_${platform}.tar.gz"
    maj_ver="$(koopa::major_version "${dict[version]}")"

    # FIXME Need to pin to major version here.

    url="https://d3gcli72yxqn2z.cloudfront.net/connect_latest/v${maj_ver]}/bin/${file}"

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
    koopa::assert_is_installed "${prefix}/bin/ascp"
    return 0
}
