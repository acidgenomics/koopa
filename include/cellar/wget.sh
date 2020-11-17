#!/usr/bin/env bash
# shellcheck disable=SC2154

if koopa::is_macos
then
    koopa::assert_is_installed brew
    openssl_pkgconfig="$(brew --prefix)/opt/openssl@1.1/lib/pkgconfig"
    koopa::assert_is_dir "$openssl_pkgconfig"
    koopa::add_to_pkg_config_path_start "$openssl_pkgconfig"
fi
file="${name}-${version}.tar.gz"
url="${gnu_mirror}/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --with-ssl='openssl'
make --jobs="$jobs"
make install
