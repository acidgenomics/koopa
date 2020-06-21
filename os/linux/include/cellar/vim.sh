#!/usr/bin/env bash
# shellcheck disable=SC2154

# Installing with Python 3 configuration.
_koopa_assert_is_installed python3
make_prefix="$(_koopa_make_prefix)"
python3_exe="${make_prefix}/bin/python3"
_koopa_assert_is_file "$python3_exe"
python3_config_exe="${python3_exe}-config"
_koopa_assert_is_file "$python3_config_exe"
python3_config_dir="$("$python3_config_exe" --configdir)"

file="v${version}.tar.gz"
url="https://github.com/${name}/${name}/archive/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --enable-python3interp="yes" \
    --with-python3-command="${python3_exe}" \
    --with-python3-config-dir="${python3_config_dir}" \
    LDFLAGS="-Wl,--rpath=${make_prefix}/lib"
make --jobs="$jobs"
# > make test
make install
