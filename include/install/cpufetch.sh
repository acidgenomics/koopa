#!/usr/bin/env bash
# shellcheck disable=SC2154

# NOTE This is failing to compile on macOS.
# use of undeclared identifier 'cpu_set_t'

koopa::assert_is_installed git make
file="v${version}.tar.gz"
url="https://github.com/Dr-Noob/cpufetch/archive/refs/tags/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
PREFIX="$prefix" make --jobs="$jobs"
make install
