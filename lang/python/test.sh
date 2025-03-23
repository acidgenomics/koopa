#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

run_pytest_cov() {
    local -A app dict
    app['pytest']="$(koopa_locate_pytest)"
    koopa_assert_is_executable "${app[@]}"
    dict['pythonpath']="$(koopa_script_parent_dir)"
    koopa_assert_is_dir "${dict['pythonpath']}"
    export PYTHONPATH="${dict['pythonpath']}"
    "${app['pytest']}" \
        --cov='tests' \
        --cov-report='term' \
        --cov-report='html' \
        --cov-fail-under=80 \
        "${dict['pythonpath']}"
    return 0
}

main() {
    run_pytest_cov
    return 0
}

main "$@"
