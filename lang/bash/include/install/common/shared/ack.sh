#!/usr/bin/env bash

main() {
    # """
    # Install ack.
    # @note Updated 2023-08-30.
    # """
    koopa_install_perl_package \
        --cpan-path='PETDANCE/ack' \
        --dependency='File::Next'
    return 0
}
