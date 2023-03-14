#!/usr/bin/env bash

koopa_install_private_ont_guppy() {
    koopa_install_app \
        --name='ont-guppy' \
        --private \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://nanoporetech.com/support/nanopore-sequencing-data-analysis'."
    return 0
}
