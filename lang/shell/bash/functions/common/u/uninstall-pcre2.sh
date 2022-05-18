#!/usr/bin/env bash

koopa_uninstall_pcre2() {
    koopa_uninstall_app \
        --name-fancy='PCRE2' \
        --name='pcre2' \
        "$@"
}
