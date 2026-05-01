#!/usr/bin/env bash

_koopa_uninstall_apache_airflow() {
    _koopa_uninstall_app \
        --name='apache-airflow' \
        "$@"
}
