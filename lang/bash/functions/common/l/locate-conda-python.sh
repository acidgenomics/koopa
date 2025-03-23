#!/usr/bin/env bash

koopa_locate_conda_python() {
    koopa_locate_app \
        --app-name='conda' \
        --bin-name='python' \
        "$@"
}
