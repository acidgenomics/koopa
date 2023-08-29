#!/usr/bin/env bash

main() {
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_perl_package \
        --cpan-path='PETDANCE/ack' \
        --dependency='File::Next' \
        --prefix="${dict['prefix']}" \
        --version="v${dict['version']}"
    return 0
}
