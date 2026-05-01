#!/usr/bin/env bash

_koopa_assert_python_venv_is_not_active() {
    # """
    # Assert that Python virtual environment is not active.
    # @note Updated 2024-09-18.
    # """
    _koopa_assert_has_no_args "$#"
    if _koopa_is_python_venv_active
    then
        _koopa_stop \
            'Active Python virtual environment detected.' \
            "Run 'deactivate' command before proceeding."
    fi
    return 0
}
