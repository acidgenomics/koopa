#!/usr/bin/env bash

koopa_install_apache_airflow() {
    koopa_install_app \
        --installer='python-package' \
        --name='apache-airflow' \
        "$@"
}
