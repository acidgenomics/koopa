#!/usr/bin/env bash

main() {
    local -A dict
    dict['cpan_path']='PETDANCE/ack'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="v${KOOPA_INSTALL_VERSION:?}"
    koopa_install_perl_package \
        --cpan-path="${dict['cpan_path']}" \
        --dependency='File::Next' \
        --prefix="${dict['prefix']}" \
        --version="${dict['version']}"
    return 0
}
