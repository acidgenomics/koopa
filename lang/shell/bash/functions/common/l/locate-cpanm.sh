#!/usr/bin/env bash

koopa_locate_cpanm() {
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='cpanm' \
        --opt-name='perl-packages' \
        "$@"
}
