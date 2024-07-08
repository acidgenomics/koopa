#!/usr/bin/env bash

koopa_install_anaconda() {
    # """
    # Install full Anaconda distribution.
    # @note Updated 2024-07-08.
    # """
    koopa_alert_note "Usage of full Anaconda distribution at an organization \
of more than 200 employees requires a Business or Enterprise license. Refer \
to 'https://www.anaconda.com/pricing' for details."
    koopa_install_app \
        --name='anaconda' \
        "$@"
}
