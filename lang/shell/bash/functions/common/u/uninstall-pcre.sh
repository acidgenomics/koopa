#!/usr/bin/env bash

koopa_uninstall_pcre() {
    koopa_uninstall_app \
        --name-fancy='PCRE' \
        --name='pcre' \
        "$@"
}
