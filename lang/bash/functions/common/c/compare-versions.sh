#!/usr/bin/env bash

koopa_compare_versions() {
    # """
    # Comparison expressions for semantic versions.
    # @note Updated 2025-03-12.
    #
    # @seealso
    # - https://github.com/awslabs/amazon-eks-ami/blob/main/templates/al2/
    #   runtime/bin/vercmp
    # - https://stackoverflow.com/questions/4023830
    #
    # @examples
    # koopa_compare_versions 2.0 >= 1.0
    # """
    local -A app dict
    local -a sorted
    koopa_assert_has_args_eq "$#" 3
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['left']="${1:?}"
    dict['operator']="${2:?}"
    dict['right']="${3:?}"
    if [[ "${dict['left']}" == "${dict['right']}" ]]
    then
        dict['comparison']=0
    else
        readarray -t sorted <<< "$( \
            koopa_print "${dict['left']}" "${dict['right']}" \
            | "${app['sort']}" -V \
        )"
        if [[ "${sorted[0]}" == "${dict['left']}" ]]
        then
            dict['comparison']=-1
        else
            dict['comparison']=1
        fi
    fi
    # return: 0 = true; 1 = false.
    dict['return']=1
    case "${dict['operator']}" in
        '-eq')
            if [[ "${dict['comparison']}" -eq 0 ]]
            then
                dict['return']=0
            fi
            ;;
        '-ge')
            if [[ "${dict['comparison']}" -gt -1 ]]
            then
                dict['return']=0
            fi
            ;;
        '-gt')
            if [[ "${dict['comparison']}" -eq 1 ]]
            then
                dict['return']=0
            fi
            ;;
        '-le')
            if [[ "${dict['comparison']}" -lt 1 ]]
            then
                dict['return']=0
            fi
            ;;
        '-lt')
            if [[ "${dict['comparison']}" -eq -1 ]]
            then
                dict['return']=0
            fi
            ;;
        *)
            koopa_stop "Invalid operator: '${dict['operator']}'."
            ;;
    esac
    return "${dict['return']}"
}
