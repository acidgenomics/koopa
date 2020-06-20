#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://github.com/Kitware/CMake
#
# Note that we're enforcing system GCC here to avoid libstdc++ errors.
#
#
# Error from GCC clobbering libstdc++:
#
# libstdc++.so.6: version `GLIBCXX_3.4.XXX' not found
# https://stackoverflow.com/questions/44773296
#
# GCC 4.9.0: libstdc++.so.6.0.20
# GCC 5.1.0: libstdc++.so.6.0.21
# GCC 6.1.0: libstdc++.so.6.0.22
# GCC 7.1.0: libstdc++.so.6.0.23
# GCC 7.2.0: libstdc++.so.6.0.24
# GCC 8.0.0: libstdc++.so.6.0.25
# [...]
# GCC 9.2.0: libstdc++.so.6.0.27
#
# GCC 9.2.0: version `GLIBCXX_3.4.26' not found
#
# Set CC and CXX globals to avoid this (see below).
# """

_koopa_assert_is_file /usr/bin/gcc /usr/bin/g++

_koopa_cd_tmp_dir "$tmp_dir"
file="cmake-${version}.tar.gz"
url="https://github.com/Kitware/CMake/releases/download/v${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
# Note that the './configure' script is just a wrapper for './bootstrap'.
export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
# > ./bootstrap --help
./bootstrap \
    --parallel="$jobs" \
    --prefix="$prefix"
make --jobs="$jobs"
make install
