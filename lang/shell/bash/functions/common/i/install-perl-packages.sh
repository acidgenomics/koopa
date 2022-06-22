#!/usr/bin/env bash

# FIXME Need to split these out into individual installers.

koopa_install_perl_packages() {
    koopa_install_app_packages \
        --link-in-bin='bin/ack' \
        --link-in-bin='bin/cpanm' \
        --link-in-bin='bin/exiftool' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}
