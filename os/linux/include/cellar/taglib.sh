#!/usr/bin/env bash
# shellcheck disable=SC2154

# FIXME Seeing this error on RHEL UBI when trying to install pytaglib:
# https://stackoverflow.com/questions/29200461/recompile-with-fpic-flag
# relocation R_X86_64_32S against symbol `_ZTVN6TagLib4RIFF3WAV4FileE' can not
# be used when making a shared object; recompile with -fPIC

file="${name}-${version}.tar.gz"
url="https://github.com/taglib/taglib/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
cmake \
    -DCMAKE_BUILD_TYPE='Release' \
    -DCMAKE_INSTALL_PREFIX="${prefix}"
make --jobs="$jobs"
make install
