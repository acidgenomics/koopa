#!/usr/bin/env bash
set -Eeu -o pipefail

# https://github.com/fish-shell/fish-shell/#building

name="fish"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="fish-3.0.2.tar.gz"
    url="https://github.com/fish-shell/fish-shell/releases/download/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "fish-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$jobs"
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
_koopa_update_shells "$name"

# > fish_config
# > fish_update_completions
