#!/usr/bin/env bash
set -Eeu -o pipefail

name="tmux"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="tmux-${version}.tar.gz"
    url="https://github.com/tmux/tmux/releases/download/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "tmux-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" -V
command -v "$exe_file"
