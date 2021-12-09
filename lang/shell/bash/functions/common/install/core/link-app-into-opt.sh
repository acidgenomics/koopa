#!/usr/bin/env bash

koopa::link_app_into_opt() { # {{{1
    # """
    # Link an application into koopa opt prefix.
    # @note Updated 2021-12-09.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 2
    declare -A dict=(
        [opt_prefix]="$(koopa::opt_prefix)"
        [source_dir]="${1:?}"
    )
    dict[target_dir]="${dict[opt_prefix]}/${2:?}"
    [[ ! -d "${dict[opt_prefix]}" ]] && koopa::mkdir "${dict[opt_prefix]}"
    # This happens during installation of app packages (e.g. Python).
    [[ "${dict[source_dir]}" == "${dict[target_dir]}" ]] && return 0
    koopa::alert "Linking '${dict[source_dir]}' in '${dict[target_dir]}'."
    [[ ! -d "${dict[source_dir]}" ]] && koopa::mkdir "${dict[source_dir]}"
    [[ -d "${dict[target_dir]}" ]] && koopa::sys_rm "${dict[target_dir]}"
    koopa::sys_set_permissions "${dict[opt_prefix]}"
    koopa::sys_ln "${dict[source_dir]}" "${dict[target_dir]}"
    return 0
}
