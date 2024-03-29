#!/usr/bin/env bash

koopa_is_variable_defined() {
    # """
    # Is the variable defined (and non-empty)?
    # @note Updated 2023-04-06.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # Note that usage of 'declare' here is a bashism.
    # Can consider using 'type' instead for POSIX compliance.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3601515
    # - https://unix.stackexchange.com/questions/504082
    # - https://www.gnu.org/software/bash/manual/html_node/
    #       Shell-Parameter-Expansion.html
    #
    # @examples
    # > koopa_is_variable_defined 'PATH'
    # """
    local -A dict
    local var
    koopa_assert_has_args "$#"
    dict['nounset']="$(koopa_boolean_nounset)"
    [[ "${dict['nounset']}" -eq 1 ]] && set +o nounset
    for var in "$@"
    do
        local x value
        # Check if variable is defined.
        x="$(declare -p "$var" 2>/dev/null || true)"
        [[ -n "${x:-}" ]] || return 1
        # Check if variable contains non-empty value.
        value="${!var}"
        [[ -n "${value:-}" ]] || return 1
    done
    [[ "${dict['nounset']}" -eq 1 ]] && set -o nounset
    return 0
}
