#!/usr/bin/env bash

name="vim"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/${name}"

# Using this to set Python 3 flags automatically below.
build_prefix="$(_acid_build_prefix)"
python3_exe="${build_prefix}/bin/python3"
python3_config_exe="${python3_exe}-config"
python3_config_dir="$("$python3_config_exe" --configdir)"

_acid_message "Installing ${name} ${version}."

(
    rm -fr "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    _acid_download "https://github.com/vim/vim/archive/v${version}.tar.gz"
    _acid_extract "v${version}.tar.gz"
    cd "vim-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-python3interp="yes" \
        --with-python3-command="${python3_exe}" \
        --with-python3-config-dir="${python3_config_dir}"
    make --jobs="$CPU_COUNT"
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
