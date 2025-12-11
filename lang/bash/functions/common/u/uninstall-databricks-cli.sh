#!/usr/bin/env bash

koopa_uninstall_databricks_cli() {
    koopa_uninstall_app \
        --name='databricks-cli' \
        "$@"
}
