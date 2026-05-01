#!/usr/bin/env bash

_koopa_getent() {
    # """
    # Get an environment variable.
    # @note Updated 2024-06-27.
    #
    # Defined in Zsh but not Bash.
    #
    # @seealso
    # - https://stackoverflow.com/questions/29357095/
    # - https://serverfault.com/questions/694206/
    #
    # @examples
    # > _koopa_getent group staff
    # # staff:*:20:root
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    app['grep']="$(_koopa_locate_grep --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    if [[ "${1:?}" == 'hosts' ]]
    then
        dict['str']="$( \
            "${app['sed']}" 's/#.*//' "/etc/${1:?}" \
            | "${app['grep']}" -w "${2:?}" \
        )"
    elif [[ "${2:?}" == '<->' ]]
    then
        dict['str']="$( \
            "${app['grep']}" ":${2:?}:[^:]*$" "/etc/${1:?}" \
        )"
    else
        dict['str']="$( \
            "${app['grep']}" "^${2:?}:" "/etc/${1:?}" \
        )"
    fi
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}
