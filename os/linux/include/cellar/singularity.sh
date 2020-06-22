#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_assert_has_sudo
_koopa_assert_is_installed go

file="singularity-${version}.tar.gz"
url="https://github.com/sylabs/singularity/releases/download/\
v${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "singularity" || exit 1
./mconfig --prefix="$prefix"
make -C builddir
sudo make -C builddir install

