#!/usr/bin/env bash

koopa_install_pcre2() {
    koopa_install_app \
        --link-in-bin='pcre2-config' \
        --link-in-bin='pcre2grep' \
        --link-in-bin='pcre2test' \
        --name='pcre2' \
        "$@"
}
