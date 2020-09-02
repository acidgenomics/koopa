#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Seeing this error on RHEL UBI when trying to install pytaglib:
# relocation R_X86_64_32S against symbol `_ZTVN6TagLib4RIFF3WAV4FileE' can not
# be used when making a shared object; recompile with -fPIC
#
# To build a static library, set the following two options with CMake:
# -DBUILD_SHARED_LIBS=OFF -DENABLE_STATIC_RUNTIME=ON
#
# How to set '-fPIC' compiler flags?
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fpic")
#
# @seealso
# - https://stackoverflow.com/questions/29200461
# - https://stackoverflow.com/questions/38296756
# - https://github.com/taglib/taglib/blob/master/INSTALL.md
# - https://github.com/eplightning/audiothumbs-frameworks/issues/2
# - https://cmake.org/pipermail/cmake/2012-June/050792.html
# - https://github.com/gabime/spdlog/issues/1190
# """

file="${name}-${version}.tar.gz"
url="https://github.com/taglib/taglib/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
cmake \
    -DBUILD_TESTS='on' \
    -DCMAKE_BUILD_TYPE='Release' \
    -DCMAKE_CXX_FLAGS='-fpic' \
    -DCMAKE_INSTALL_PREFIX="${prefix}"
make --jobs="$jobs"
make check
make install
