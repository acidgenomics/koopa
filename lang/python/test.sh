#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

run_pytest_cov() {
    local -A app dict
    app['pytest']="$(koopa_locate_pytest)"
    koopa_assert_is_executable "${app[@]}"
    dict['python_prefix']="$(koopa_python_prefix)"
    dict['module_prefix']="${dict['python_prefix']}/koopa"
    koopa_assert_is_dir "${dict['python_prefix']}" "${dict['module_prefix']}"
    export PYTHONPATH="${dict['module_prefix']}"
    "${app['pytest']}" \
        --cov='koopa' \
        --cov-report='term' \
        --cov-report='html' \
        --cov-fail-under=80 \
        "${dict['python_prefix']}"
    return 0
}

main() {
    run_pytest_cov
    return 0
}

main "$@"
