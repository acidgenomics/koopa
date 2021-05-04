#!/usr/bin/env bash

install_docker_credential_pass() { # {{{1
    # """
    # Install docker-credential-pass.
    # @note Updated 2021-04-28.
    # """
    local arch file name prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='docker-credential-pass'
    arch="$(koopa::arch)"
    file="${name}-v${version}-${arch}.tar.gz"
    url="https://github.com/docker/docker-credential-helpers/releases/\
    download/v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    chmod 0775 "$name"
    koopa::mkdir "${prefix}/bin"
    koopa::sys_set_permissions -r "$prefix"
    koopa::cp -t "${prefix}/bin" "$name"
    return 0
}

install_docker_credential_pass "$@"
