#!/usr/bin/env bash
# shellcheck disable=SC2154

# Installing with Python 3 configuration.
koopa::assert_is_installed python3
make_prefix="$(koopa::make_prefix)"
python3_exe="${make_prefix}/bin/python3"
koopa::assert_is_file "$python3_exe"
python3_config_exe="${python3_exe}-config"
koopa::assert_is_file "$python3_config_exe"
python3_config_dir="$("$python3_config_exe" --configdir)"

file="v${version}.tar.gz"
url="https://github.com/${name}/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --enable-python3interp="yes" \
    --with-python3-command="${python3_exe}" \
    --with-python3-config-dir="${python3_config_dir}" \
    LDFLAGS="-Wl,--rpath=${make_prefix}/lib"
make --jobs="$jobs"
# > make test
make install
