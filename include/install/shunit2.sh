#!/usr/bin/env bash

file="v${version}.tar.gz"
url="https://github.com/kward/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
koopa::cp -t "${prefix}/bin" "$name"
