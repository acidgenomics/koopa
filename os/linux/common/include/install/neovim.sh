#!/usr/bin/env bash
# shellcheck disable=SC2154

# Skip building on CentOS.
if koopa::is_centos
then
    koopa::note "'${name}' currently won't build on CentOS."
    return 0
fi
koopa::assert_is_linux
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
