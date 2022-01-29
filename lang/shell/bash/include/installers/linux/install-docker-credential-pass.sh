#!/usr/bin/env bash

koopa:::linux_install_docker_credential_pass() { # {{{1
    # """
    # Install docker-credential-pass.
    # @note Updated 2022-01-29.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [name]='docker-credential-pass'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[arch]}" in
        'x86_64')
            dict[arch2]='amd64'
            ;;
        *)
            dict[arch2]='arch'
            ;;
    esac
    dict[file]="${dict[name]}-v${dict[version]}-${dict[arch2]}.tar.gz"
    dict[url]="https://github.com/docker/docker-credential-helpers/releases/\
download/v${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::chmod '0775' "${dict[name]}"
    koopa::mkdir "${dict[prefix]}/bin"
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    koopa::cp "${dict[name]}" "${dict[prefix]}/bin"
    return 0
}
