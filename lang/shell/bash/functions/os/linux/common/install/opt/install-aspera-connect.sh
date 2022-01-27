#!/usr/bin/env bash

koopa:::linux_install_aspera_connect() { # {{{1
    # """
    # Install Aspera Connect.
    # @note Updated 2022-01-27.
    #
    # Script install target is currently hard-coded in IBM's install script.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [aspera_user_prefix]="${HOME}/.aspera"
        [name]='ibm-aspera-connect'
        [platform]='linux'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_ver]="$(koopa::major_version "${dict[version]}")"
    dict[file]="${dict[name]}_${dict[version]}_${dict[platform]}.tar.gz"
    dict[url]="https://d3gcli72yxqn2z.cloudfront.net/connect_latest/\
v${dict[maj_ver]]}/bin/${dict[file]}"
    dict[script]="${dict[file]//.tar.gz/.sh}"
    dict[script_target]="${dict[aspera_user_prefix]}/connect"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    "./${dict[script]}"
    koopa::assert_is_dir "${dict[script_target]}"
    if [[ "${dict[prefix]}" != "${dict[script_target]}" ]]
    then
        koopa::cp "${dict[script_target]}" "${dict[prefix]}"
        koopa::rm "${dict[script_target]}" "${dict[aspera_user_prefix]}"
    fi
    koopa::assert_is_installed "${dict[prefix]}/bin/ascp"
    return 0
}
