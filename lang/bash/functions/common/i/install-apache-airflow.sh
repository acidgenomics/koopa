#!/usr/bin/env bash

koopa_install_apache_airflow() {
    koopa_install_app \
        --installer='python-package' \
        --name='apache-airflow' \
        -D --egg-name='apache_airflow_core' \
        -D --python-version='3.13' \
        "$@"
}
