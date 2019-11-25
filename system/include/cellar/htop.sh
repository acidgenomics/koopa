#!/usr/bin/env bash
set -Eeu -o pipefail

_koopa_assert_is_installed python

name="htop"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="htop-${version}.tar.gz"
    url="https://hisham.hm/htop/releases/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "htop-${version}" || exit 1
    ./configure \
        --build="$build" \
        --disable-unicode \
        --prefix="$prefix"
    make --jobs="$jobs"
    make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
