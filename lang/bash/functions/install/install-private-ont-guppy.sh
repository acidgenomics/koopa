#!/usr/bin/env bash

_koopa_install_private_ont_guppy() {
    _koopa_install_app \
        --name='ont-guppy' \
        --private \
        "$@"
    _koopa_alert_note "Installation requires agreement to terms of service at: \
'https://nanoporetech.com/support/nanopore-sequencing-data-analysis'."
    return 0
}
