#!/usr/bin/env bash

# FIXME Installer isn't currently working:
# Returning 'Array is empty' error.
# FIXME Need to debug this install stack...

linux_install_docker_credential_pass() { # {{{1
    # """
    # Install docker-credential-pass.
    # @note Updated 2022-01-29.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa_arch)"
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
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_chmod '0775' "${dict[name]}"
    koopa_mkdir "${dict[prefix]}/bin"
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_cp "${dict[name]}" "${dict[prefix]}/bin"
    return 0
}
