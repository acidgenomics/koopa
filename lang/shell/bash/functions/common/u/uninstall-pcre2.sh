#!/usr/bin/env bash

koopa_uninstall_pcre2() {
    koopa_uninstall_app \
        --unlink-in-bin='pcre2-config' \
        --unlink-in-bin='pcre2grep' \
        --unlink-in-bin='pcre2test' \
        --name='pcre2' \
        "$@"
}
