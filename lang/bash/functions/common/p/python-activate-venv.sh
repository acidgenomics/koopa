#!/usr/bin/env bash

koopa_python_activate_venv() {
    # """
    # Activate Python virtual environment.
    # @note Updated 2023-04-06.
    #
    # Note that we're using this instead of conda as our default interactive
    # Python environment, so we can easily use pip.
    #
    # Here's how to write a function to detect virtual environment name:
    # https://stackoverflow.com/questions/10406926
    #
    # Only attempt to autoload for bash or zsh.
    #
    # This needs to be run last, otherwise PATH can get messed upon
    # deactivation, due to venv's current poor approach via '_OLD_VIRTUAL_PATH'.
    #
    # Refer to 'declare -f deactivate' for function source code.
    #
    # @examples
    # > koopa_python_activate_venv 'pandas'
    # """
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['active_env']="${VIRTUAL_ENV:-}"
    dict['name']="${1:?}"
    dict['nounset']="$(koopa_boolean_nounset)"
    dict['prefix']="$(koopa_python_virtualenvs_prefix)"
    dict['script']="${dict['prefix']}/${dict['name']}/bin/activate"
    koopa_assert_is_readable "${dict['script']}"
    if [[ -n "${dict['active_env']}" ]]
    then
        koopa_python_deactivate_venv "${dict['active_env']}"
    fi
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    # shellcheck source=/dev/null
    source "${dict['script']}"
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}
