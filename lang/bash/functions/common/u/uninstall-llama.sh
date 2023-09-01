#!/usr/bin/env bash

koopa_uninstall_llama() {
    # NOTE Deprecated. Renamed to 'walk'.
    koopa_uninstall_app \
        --name='llama' \
        "$@"
}
