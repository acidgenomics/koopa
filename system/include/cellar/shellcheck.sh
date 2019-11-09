#!/usr/bin/env bash

_acid_assert_has_no_args "$@"

name="shellcheck"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="shellcheck-v${version}.linux.x86_64.tar.xz"
    url="https://storage.googleapis.com/shellcheck/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    mkdir -pv "${prefix}/bin"
    cp "shellcheck-v${version}/shellcheck" "${prefix}/bin"
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
