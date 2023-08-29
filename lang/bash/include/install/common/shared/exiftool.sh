#!/usr/bin/env bash

main() {
    # """
    # Ensure release is tagged production before submitting.
    # https://exiftool.org/history.html
    # """
    local -A dict
    dict['cpan_path']='EXIFTOOL/Image-ExifTool'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_perl_package \
        --cpan-path="${dict['cpan_path']}" \
        --prefix="${dict['prefix']}" \
        --version="${dict['version']}"
    return 0
}
