#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::exit_if_docker

file="docker-credential-pass-v${version}-amd64.tar.gz"
url="https://github.com/docker/docker-credential-helpers/releases/\
download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
chmod 0775 docker-credential-pass
koopa::mkdir "${prefix}/bin"
koopa::sys_set_permissions --recursive "$prefix"
cp -v docker-credential-pass "${prefix}/bin/."
