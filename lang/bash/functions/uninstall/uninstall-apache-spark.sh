#!/usr/bin/env bash

_koopa_uninstall_apache_spark() {
    _koopa_uninstall_app \
        --name='apache-spark' \
        "$@"
}
