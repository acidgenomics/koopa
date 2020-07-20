#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://github.com/Kitware/CMake
# We're enforcing system GCC here to avoid libstdc++ errors.
# """

koopa::assert_is_file /usr/bin/gcc /usr/bin/g++
export CC='/usr/bin/gcc'
export CXX='/usr/bin/g++'
file="cmake-${version}.tar.gz"
url="https://github.com/Kitware/CMake/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
# Note that the './configure' script is just a wrapper for './bootstrap'.
# > ./bootstrap --help
./bootstrap \
    --parallel="$jobs" \
    --prefix="$prefix"
make --jobs="$jobs"
make install
