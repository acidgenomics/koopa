#!/usr/bin/env bash

# Install Tmux terminal multiplexer.
# Updated 2019-09-17.

# See also:
# - https://github.com/tmux/tmux

_koopa_assert_has_no_environments

name="tmux"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz"
    tar -xzvf "tmux-${version}.tar.gz"
    cd "tmux-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
    rm -fr "$tmp_dir"
)

link-cellar "$name" "$version"

"$exe_file" -V
command -v "$exe_file"
