#!/usr/bin/env bash

koopa_uninstall_apache_airflow() {
    koopa_uninstall_app \
        --name='apache-airflow' \
        "$@"
}
