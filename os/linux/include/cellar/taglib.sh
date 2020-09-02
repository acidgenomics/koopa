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
# @seealso
# - https://stackoverflow.com/questions/29200461/recompile-with-fpic-flag
# - https://github.com/taglib/taglib/blob/master/INSTALL.md
# - https://github.com/eplightning/audiothumbs-frameworks/issues/2
# """

file="${name}-${version}.tar.gz"
url="https://github.com/taglib/taglib/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
cmake \
    -DBUILD_TESTS='on' \
    -DCMAKE_BUILD_TYPE='Release' \
    -DCMAKE_INSTALL_PREFIX="${prefix}" \
    -fPIC
make --jobs="$jobs"
make check
make install
