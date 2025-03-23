#!/usr/bin/env bash

koopa_uninstall_apache_spark() {
    koopa_uninstall_app \
        --name='apache-spark' \
        "$@"
}
