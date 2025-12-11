#!/usr/bin/env bash

koopa_install_databricks_cli() {
    koopa_install_app \
        --installer='conda-package' \
        --name='databricks-cli' \
        "$@"
}
