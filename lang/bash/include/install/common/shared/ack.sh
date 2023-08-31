#!/usr/bin/env bash

main() {
    # """
    # Install ack.
    # @note Updated 2023-08-31.
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_perl_package \
        --cpan-path='PETDANCE/ack' \
        --dependency='File::Next' \
        --version="v${dict['version']}"
    return 0
}
