#!/usr/bin/env bash

koopa_is_python_venv_active() {
    # """
    # Is there a Python virtual environment active?
    # @note Updated 2025-08-07.
    #
    # Some servers set VIRTUAL_ENV for non-Python virtual environment.
    # This is non-standard. Python venv activation also sets VIRTUAL_ENV_PROMPT,
    # so let's check for that here as well.
    # """
    [[ -n "${VIRTUAL_ENV:-}" ]] && [[ -n "${VIRTUAL_ENV_PROMPT:-}" ]]
}
