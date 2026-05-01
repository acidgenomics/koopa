#!/usr/bin/env bash

_koopa_macos_locate_ld_classic() {
    _koopa_locate_app \
        '/Library/Developer/CommandLineTools/usr/bin/ld-classic' \
        "$@"
}
