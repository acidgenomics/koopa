#!/usr/bin/env bash
set -Eeu -o pipefail

name="vim"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

# Using this to set Python 3 flags automatically below.
build_prefix="$(_koopa_make_prefix)"
python3_exe="${build_prefix}/bin/python3"
python3_config_exe="${python3_exe}-config"
python3_config_dir="$("$python3_config_exe" --configdir)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    _koopa_download "https://github.com/vim/vim/archive/v${version}.tar.gz"
    _koopa_extract "v${version}.tar.gz"
    cd "vim-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix" \
        --enable-python3interp="yes" \
        --with-python3-command="${python3_exe}" \
        --with-python3-config-dir="${python3_config_dir}"
    make --jobs="$jobs"
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
