#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2.sig"
_koopa_download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2"
if _koopa_is_installed gpg-agent
then
    gpg --verify "${name}-${version}.tar.bz2.sig"
fi
_koopa_extract "${name}-${version}.tar.bz2"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
