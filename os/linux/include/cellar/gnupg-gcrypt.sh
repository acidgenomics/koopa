#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2.sig"
koopa::download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2"
if koopa::is_installed gpg-agent
then
    gpg --verify "${name}-${version}.tar.bz2.sig"
fi
koopa::extract "${name}-${version}.tar.bz2"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
