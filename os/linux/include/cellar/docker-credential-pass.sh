#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_exit_if_docker

file="docker-credential-pass-v${version}-amd64.tar.gz"
url="https://github.com/docker/docker-credential-helpers/releases/\
download/v${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
chmod 0775 docker-credential-pass
_koopa_mkdir "${prefix}/bin"
_koopa_set_permissions --recursive "$prefix"
cp -v docker-credential-pass "${prefix}/bin/."
