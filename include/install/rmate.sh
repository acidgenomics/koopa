#!/usr/bin/env bash

file="v${version}.tar.gz"
url="https://github.com/aurora/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
chmod a+x rmate
koopa::mkdir "${prefix}/bin"
koopa::cp -t "${prefix}/bin" 'rmate'
