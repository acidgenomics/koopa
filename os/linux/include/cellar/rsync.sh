#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://download.samba.org/pub/${name}/src/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
flags=(
    "--disable-zstd"
    "--prefix=${prefix}"
    # "--without-included-zlib"
)
if _koopa_is_rhel
then
    flags+=("--disable-xxhash")
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
