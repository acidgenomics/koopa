#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://www.passwordstore.org/
# https://git.zx2c4.com/password-store/
# """

koopa::assert_is_linux
file="${name}-${version}.tar.xz"
url="https://git.zx2c4.com/${name}/snapshot/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
PREFIX="$prefix" make install
