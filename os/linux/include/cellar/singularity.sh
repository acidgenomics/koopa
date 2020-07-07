#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_has_sudo
koopa::assert_is_installed go

file="singularity-${version}.tar.gz"
url="https://github.com/sylabs/singularity/releases/download/\
v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "singularity" || exit 1
./mconfig --prefix="$prefix"
make -C builddir
sudo make -C builddir install

