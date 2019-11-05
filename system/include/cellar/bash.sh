#!/usr/bin/env bash

_koopa_assert_has_no_args "$@"

name="bash"
version="$(_koopa_variable "$name")"
major_version="$(_koopa_major_version "$version")"
patches="$(echo "$version" | cut -d '.' -f 3)"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
gnu_mirror="https://ftpmirror.gnu.org"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="bash-${major_version}.tar.gz"
    url="${gnu_mirror}/bash/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "bash-${major_version}" || exit 1
    # Apply patches. Can pipe curl call directly to 'patch -p0' instead.
    (
        mkdir -pv patches
        cd patches || exit 1
        base_url="https://ftp.gnu.org/gnu/bash/bash-${major_version}-patches"
        mv_tr="$(echo "$major_version" | tr -d '.')"
        range="$(printf "%03d-%03d" "1" "$patches")"
        request="${base_url}/bash${mv_tr}-[${range}]"
        _koopa_download "$request"
        cd .. || exit 1
        for file in patches/*
        do
            patch -p0 --input="$file"
        done
    )
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
_koopa_update_shells "$name"

"$exe_file" --version
command -v "$exe_file"
