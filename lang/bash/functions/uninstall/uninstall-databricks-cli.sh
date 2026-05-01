#!/usr/bin/env bash

_koopa_uninstall_databricks_cli() {
    _koopa_uninstall_app \
        --name='databricks-cli' \
        "$@"
}
