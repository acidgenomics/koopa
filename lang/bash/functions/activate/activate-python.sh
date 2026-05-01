#!/usr/bin/env bash

_koopa_activate_python() {
    if [[ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [[ -z "${PYTHONDONTWRITEBYTECODE:-}" ]]
    then
        export PYTHONDONTWRITEBYTECODE=1
    fi
    if [[ -z "${PYTHONSTARTUP:-}" ]]
    then
        local startup_file
        startup_file="${HOME:?}/.pyrc"
        if [[ -f "$startup_file" ]]
        then
            export PYTHONSTARTUP="$startup_file"
        fi
    fi
    if [[ -z "${PYTHONWARNINGS:-}" ]]
    then
        export PYTHONWARNINGS='ignore::SyntaxWarning'
    fi
    if [[ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}
