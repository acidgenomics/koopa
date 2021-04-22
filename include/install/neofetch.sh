#!/usr/bin/env bash
# 
file="${version}.tar.gz"
url="https://github.com/dylanaraps/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
koopa::mkdir "$prefix"
make PREFIX="$prefix" install
