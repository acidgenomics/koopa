#!/usr/bin/env bash

_acid_assert_is_installed python

name="htop"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="htop-${version}.tar.gz"
    url="https://hisham.hm/htop/releases/${version}/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "htop-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --disable-unicode \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
