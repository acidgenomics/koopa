#!/usr/bin/env bash

koopa_view_latest_tmp_log_file() {
    # """
    # View the latest temporary log file.
    # @note Updated 2022-01-17.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [tmp_dir]="${TMPDIR:-/tmp}"
        [user_id]="$(koopa_user_id)"
    )
    dict[log_file]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="koopa-${dict[user_id]}-*" \
            --prefix="${dict[tmp_dir]}" \
            --sort \
            --type='f' \
        | "${app[tail]}" -n 1 \
    )"
    if [[ ! -f "${dict[log_file]}" ]]
    then
        koopa_stop "No koopa log file detected in '${dict[tmp_dir]}'."
    fi
    koopa_alert "Viewing '${dict[log_file]}'."
    # The use of '+G' flag here forces pager to return at end of line.
    koopa_pager +G "${dict[log_file]}"
    return 0
}

koopa_warn_if_export() {
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_export "$arg"
        then
            koopa_warn "'${arg}' is exported."
        fi
    done
    return 0
}

koopa_which_function() {
    # """
    # Locate a koopa function automatically.
    # @note Updated 2022-04-29.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    declare -A dict=(
        [input_key]="${1:?}"
    )
    if koopa_is_function "${dict[input_key]}"
    then
        koopa_print "${dict[input_key]}"
        return 0
    fi
    dict[key]="${dict[input_key]//-/_}"
    dict[os_id]="$(koopa_os_id)"
    if koopa_is_function "koopa_${dict[os_id]}_${dict[key]}"
    then
        dict[fun]="koopa_${dict[os_id]}_${dict[key]}"
    elif koopa_is_rhel_like && \
        koopa_is_function "koopa_rhel_${dict[key]}"
    then
        dict[fun]="koopa_rhel_${dict[key]}"
    elif koopa_is_debian_like && \
        koopa_is_function "koopa_debian_${dict[key]}"
    then
        dict[fun]="koopa_debian_${dict[key]}"
    elif koopa_is_fedora_like && \
        koopa_is_function "koopa_fedora_${dict[key]}"
    then
        dict[fun]="koopa_fedora_${dict[key]}"
    elif koopa_is_linux && \
        koopa_is_function "koopa_linux_${dict[key]}"
    then
        dict[fun]="koopa_linux_${dict[key]}"
    else
        dict[fun]="koopa_${dict[key]}"
    fi
    koopa_is_function "${dict[fun]}" || return 1
    koopa_print "${dict[fun]}"
    return 0
}
