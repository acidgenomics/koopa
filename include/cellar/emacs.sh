#!/usr/bin/env bash
# shellcheck disable=SC2154

file="emacs-${version}.tar.xz"
url="${gnu_mirror}/emacs/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "emacs-${version}"
./configure \
    --prefix="$prefix" \
    --with-x-toolkit='no' \
    --with-xpm='no'
make --jobs="$jobs"
make install
