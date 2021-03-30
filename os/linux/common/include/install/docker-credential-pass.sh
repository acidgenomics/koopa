#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_is_linux
arch="$(koopa::arch)"
file="docker-credential-pass-v${version}-${arch}.tar.gz"
url="https://github.com/docker/docker-credential-helpers/releases/\
download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
chmod 0775 'docker-credential-pass'
koopa::mkdir "${prefix}/bin"
koopa::sys_set_permissions -r "$prefix"
koopa::cp -t "${prefix}/bin" 'docker-credential-pass'
