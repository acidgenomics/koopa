#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Installing with Python 3 configuration.
# """

make_prefix="$(koopa::make_prefix)"
python3="${make_prefix}/bin/python3"
python3_config="${python3}-config"
koopa::assert_is_installed "$python3" "$python3_config"
python3_config_dir="$("$python3_config" --configdir)"
file="v${version}.tar.gz"
url="https://github.com/${name}/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --enable-python3interp='yes' \
    --with-python3-command="$python3" \
    --with-python3-config-dir="${python3_config_dir}" \
    LDFLAGS="-Wl,--rpath=${make_prefix}/lib"
make --jobs="$jobs"
# > make test
make install
