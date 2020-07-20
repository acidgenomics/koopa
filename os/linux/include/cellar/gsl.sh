#!/usr/bin/env bash
# shellcheck disable=SC2154

file="gsl-${version}.tar.gz"
url="http://mirror.keystealth.org/gnu/gsl/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "gsl-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
