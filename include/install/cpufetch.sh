#!/usr/bin/env bash
# 
# NOTE v0.94 stable release fails to compile on macOS.
# use of undeclared identifier 'cpu_set_t'
# https://github.com/Dr-Noob/cpufetch/issues/38

koopa::assert_is_installed git make
case "$version" in
    0.96)
        # No stable release for this yet, use master branch.
        git clone "https://github.com/Dr-Noob/${name}.git"
        koopa::cd "$name"
        ;;
    *)
        file="v${version}.tar.gz"
        url="https://github.com/Dr-Noob/cpufetch/archive/refs/tags/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::cd "${name}-${version}"
        ;;
esac
# Installer doesn't currently support 'configure' script.
PREFIX="$prefix" make --jobs="$jobs"
PREFIX="$prefix" make install
