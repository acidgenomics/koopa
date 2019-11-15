#!/usr/bin/env bash
set -Eeu -o pipefail

_koopa_assert_is_installed python

name="htop"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="htop-${version}.tar.gz"
    url="https://hisham.hm/htop/releases/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "htop-${version}" || exit 1
    ./configure \
        --build="$build" \
        --disable-unicode \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
