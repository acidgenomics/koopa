#!/usr/bin/env bash

_koopa_help "$@"
_koopa_assert_has_no_args "$@"

name="neovim"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/nvim"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/${name}/${name}/archive/v${version}.tar.gz"
    _koopa_extract "v${version}.tar.gz"
    cd "${name}-${version}" || exit 1
    make \
        --jobs="$CPU_COUNT" \
        CMAKE_BUILD_TYPE=Release \
        CMAKE_INSTALL_PREFIX="$prefix"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
