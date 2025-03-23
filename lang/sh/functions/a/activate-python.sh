#!/bin/sh

_koopa_activate_python() {
    # """
    # Activate Python, including custom installed packages.
    # @note Updated 2025-02-27.
    #
    # Configures:
    # - Site packages library.
    # - Custom startup file, defined in our 'dotfiles' repo.
    #
    # This ensures that 'bin' will be added to PATH, which is useful when
    # installing via pip with '--target' flag.
    #
    # Check path configuration with:
    # > python3 -c "import sys; print('\n'.join(sys.path))"
    #
    # Check which pip with:
    # > python3 -m pip show pip
    #
    # @seealso
    # - https://docs.python.org/3/tutorial/modules.html#the-module-search-path
    # - https://stackoverflow.com/questions/33683744/
    # - https://twitter.com/sadhlife/status/1450459992419622920
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # """
    if [ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [ -z "${PYTHONDONTWRITEBYTECODE:-}" ]
    then
        export PYTHONDONTWRITEBYTECODE=1
    fi
    # Added in Python 3.11.
    # This messes with Google Cloud SDK currently, so disabling.
    # https://github.com/GoogleCloudPlatform/gsutil/issues/1735
    # > if [ -z "${PYTHONSAFEPATH:-}" ]
    # > then
    # >     export PYTHONSAFEPATH=1
    # > fi
    if [ -z "${PYTHONSTARTUP:-}" ]
    then
        __kvar_startup_file="${HOME:?}/.pyrc"
        if [ -f "$__kvar_startup_file" ]
        then
            export PYTHONSTARTUP="$__kvar_startup_file"
        fi
        unset -v __kvar_startup_file
    fi
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}
