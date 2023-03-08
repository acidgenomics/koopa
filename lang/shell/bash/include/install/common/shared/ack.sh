#!/usr/bin/env bash

# FIXME This is failing tests due to 'File::Next' missing.

main() {
    koopa_install_app_subshell \
        --installer='perl-package' \
        --name='ack' \
        "$@"
}
