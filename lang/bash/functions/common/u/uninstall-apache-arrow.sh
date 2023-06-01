#!/usr/bin/env bash

koopa_uninstall_apache_arrow() {
    koopa_uninstall_app \
        --name='apache-arrow' \
        "$@"
}
