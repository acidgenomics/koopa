#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
# HTTP alternative:
# > url="https://www.unidata.ucar.edu/downloads/${name}/${file}"
url="ftp://ftp.unidata.ucar.edu/pub/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
