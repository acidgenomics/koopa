#!/usr/bin/env bash

main() {
    # """
    # Install Apache Airflow.
    # @note Updated 2022-09-28.
    #
    # Use 'airflow standalone' to configure for current user. Use this for
    # development only, not production. The 'standalone' command will initialise
    # the database, make a user, and start all components for you. Visit
    # 'localhost:8080' in the browser and use the admin account details shown on
    # the terminal to login.
    #
    # Change the default configuration target with 'AIRFLOW_HOME'.
    # """
    koopa_install_app_subshell \
        --installer='python-package' \
        --name='apache-airflow' \
        -D --package-name='apache_airflow'
}
