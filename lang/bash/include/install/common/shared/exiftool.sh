#!/usr/bin/env bash

# TODO Consider adding recommended 'Unicode::UTF8' module.

main() {
    # """
    # Install exiftool.
    # @note Updated 2023-08-30.
    #
    # Ensure release is tagged production before submitting.
    # https://exiftool.org/history.html
    # """
    koopa_install_perl_package --cpan-path='EXIFTOOL/Image-ExifTool'
    return 0
}
