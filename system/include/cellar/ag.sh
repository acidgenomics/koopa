#!/usr/bin/env bash
set -Eeu -o pipefail

name="ag"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="v${version}.tar.gz"
    url="https://github.com/ggreer/the_silver_searcher/archive/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "git-${version}" || exit 1
    make configure
    ./configure \
        --build="$build" \
        --prefix="$prefix" \
        --with-openssl="/bin/openssl"
    # This is now erroring on RHEL 7.7:
    # > make --jobs="$jobs" all doc info
    # > make install install-doc install-html install-info
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
