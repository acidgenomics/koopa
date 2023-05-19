#!/usr/bin/env bash

koopa_install_apache_airflow() {
    koopa_install_app \
        --name='apache-airflow' \
        "$@"
}
