#!/usr/bin/env bash
# shellcheck disable=SC2154

file="gsl-${version}.tar.gz"
url="http://mirror.keystealth.org/gnu/gsl/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "gsl-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
