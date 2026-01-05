#!/usr/bin/env bash

koopa_locate_python() {
    local -A dict
    dict['python_version']="$(koopa_python_major_minor_version)"
    koopa_locate_app \
        --app-name="python${dict['python_version']}" \
        --bin-name="python${dict['python_version']}" \
        --system-bin-name='python3' \
        "$@"
}
