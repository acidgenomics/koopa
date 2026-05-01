#!/usr/bin/env bash

_koopa_git_submodule_init() {
    # """
    # Initialize git submodules.
    # @note Updated 2023-04-05.
    # """
    local -A app
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            local -A dict
            local -a lines
            local string
            dict['module_file']='.gitmodules'
            repo="$(_koopa_realpath "$repo")"
            _koopa_alert "Initializing submodules in '${repo}'."
            _koopa_cd "$repo"
            _koopa_assert_is_git_repo
            _koopa_assert_is_nonzero_file "${dict['module_file']}"
            "${app['git']}" submodule init
            readarray -t lines <<< "$(
                "${app['git']}" config \
                    --file "${dict['module_file']}" \
                    --get-regexp '^submodule\..*\.path$' \
            )"
            if _koopa_is_array_empty "${lines[@]:-}"
            then
                _koopa_stop "Failed to detect submodules in '${repo}'."
            fi
            for string in "${lines[@]}"
            do
                local -A dict2
                # shellcheck disable=SC2016
                dict2['target_key']="$( \
                    _koopa_print "$string" \
                    | "${app['awk']}" '{ print $1 }' \
                )"
                # shellcheck disable=SC2016
                dict2['target']="$( \
                    _koopa_print "$string" \
                    | "${app['awk']}" '{ print $2 }' \
                )"
                dict2['url_key']="${dict2['target_key']//\.path/.url}"
                dict2['url']="$( \
                    "${app['git']}" config \
                        --file "${dict['module_file']}" \
                        --get "${dict2['url_key']}" \
                )"
                _koopa_dl "${dict2['target']}" "${dict2['url']}"
                if [[ ! -d "${dict2['target']}" ]]
                then
                    "${app['git']}" submodule add --force \
                        "${dict2['url']}" "${dict2['target']}" > /dev/null
                fi
            done
        done
    )
    return 0
}
