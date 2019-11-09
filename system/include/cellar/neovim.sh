#!/usr/bin/env bash

_acid_assert_has_no_args "$@"

name="neovim"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
exe_file="${prefix}/bin/nvim"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "${name}-${version}" || exit 1
    make \
        --jobs="$CPU_COUNT" \
        CMAKE_BUILD_TYPE=Release \
        CMAKE_INSTALL_PREFIX="$prefix"
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
