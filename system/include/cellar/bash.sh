#!/usr/bin/env bash

name="bash"
version="$(_acid_variable "$name")"
major_version="$(_acid_major_version "$version")"
patches="$(echo "$version" | cut -d '.' -f 3)"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
gnu_mirror="https://ftpmirror.gnu.org"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="bash-${major_version}.tar.gz"
    url="${gnu_mirror}/bash/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "bash-${major_version}" || exit 1
    # Apply patches. Can pipe curl call directly to 'patch -p0' instead.
    (
        mkdir -pv patches
        cd patches || exit 1
        base_url="https://ftp.gnu.org/gnu/bash/bash-${major_version}-patches"
        mv_tr="$(echo "$major_version" | tr -d '.')"
        range="$(printf "%03d-%03d" "1" "$patches")"
        request="${base_url}/bash${mv_tr}-[${range}]"
        # > _acid_download "$request"
        curl "$request" -O
        cd .. || exit 1
        for file in patches/*
        do
            # https://stackoverflow.com/questions/14282617
            patch -p0 --ignore-whitespace --input="$file"
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

_acid_link_cellar "$name" "$version"
_acid_update_shells "$name"

"$exe_file" --version
command -v "$exe_file"
