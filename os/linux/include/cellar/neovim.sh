#!/usr/bin/env bash
# shellcheck disable=SC2154

# Skip building on CentOS.
if koopa::is_centos
then
    koopa::exit "'${name}' currently won't build on CentOS."
fi

file="v${version}.tar.gz"
url="https://github.com/${name}/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
make \
    --jobs="$jobs" \
    CMAKE_BUILD_TYPE=Release \
    CMAKE_INSTALL_PREFIX="$prefix"
make install
