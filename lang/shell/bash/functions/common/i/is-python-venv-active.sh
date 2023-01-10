#!/usr/bin/env bash

koopa_is_python_venv_active() {
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2023-01-10.
    # """
    [[ -n "${VIRTUAL_ENV:-}" ]]
}
