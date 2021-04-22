#!/usr/bin/env bash
# 
koopa::assert_has_sudo
koopa::assert_is_installed go
file="${name}-${version}.tar.gz"
url="https://github.com/sylabs/${name}/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "$name"
./mconfig --prefix="$prefix"
make -C builddir
sudo make -C builddir install

