#!/usr/bin/env bash

# FIXME Rework using dict approach.
koopa:::linux_install_docker_credential_pass() { # {{{1
    # """
    # Install docker-credential-pass.
    # @note Updated 2021-04-28.
    # """
    local arch arch2 file name prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='docker-credential-pass'
    arch="$(koopa::arch)"
    case "$arch" in
        'x86_64')
            arch2='amd64'
            ;;
        *)
            arch2='arch'
            ;;
    esac
    file="${name}-v${version}-${arch2}.tar.gz"
    url="https://github.com/docker/docker-credential-helpers/releases/\
download/v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::chmod '0775' "$name"
    koopa::mkdir "${prefix}/bin"
    koopa::sys_set_permissions --recursive "$prefix"
    koopa::cp "$name" "${prefix}/bin"
    return 0
}
