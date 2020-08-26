#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://github.com/taglib/taglib/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
cmake \
    -DCMAKE_BUILD_TYPE='Release' \
    -DCMAKE_INSTALL_PREFIX="${prefix}"
make --jobs="$jobs"
make install
