#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Installing with Python 3 configuration.
# """

koopa::assert_is_linux
make_prefix="$(koopa::make_prefix)"
python3='python3'
python3_config="${python3}-config"
koopa::assert_is_installed "$python3" "$python3_config"
python3_config_dir="$("$python3_config" --configdir)"
file="v${version}.tar.gz"
url="https://github.com/${name}/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
flags=(
    "--prefix=${prefix}"
    "--with-python3-command=${python3}"
    "--with-python3-config-dir=${python3_config_dir}"
    '--enable-python3interp=yes'
)
if koopa::is_linux
then
    flags+=("LDFLAGS=-Wl,--rpath=${make_prefix}/lib")
fi
# This step still fails due to macOS SDK headers:
# > if koopa::is_macos
# > then
# >     koopa::assert_is_installed brew
# >     gcc_prefix="$(brew --prefix)/opt/gcc"
# >     koopa::assert_is_dir "$gcc_prefix"
# >     flags+=(
# >         "CC=${gcc_prefix}/bin/gcc-10"
# >     )
# > fi
./configure "${flags[@]}"
make --jobs="$jobs"
# > make test
make install
