#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

run_pytest_cov() {
    local python_prefix
    python_prefix="$(koopa_python_prefix)"
    export PYTHONPATH="${python_prefix}/koopa"
    pytest \
        --cov='koopa' \
        --cov-report='term' \
        --cov-report='html' \
        --cov-fail-under=80 \
        "$python_prefix"
    return 0
}

main() {
    run_pytest_cov
    return 0
}

main "$@"
