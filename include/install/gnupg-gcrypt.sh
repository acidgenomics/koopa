#!/usr/bin/env bash
# 
# > koopa::download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2.sig"
koopa::download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2"
# > if koopa::is_installed gpg-agent
# > then
# >     gpg --verify "${name}-${version}.tar.bz2.sig"
# > fi
koopa::extract "${name}-${version}.tar.bz2"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
