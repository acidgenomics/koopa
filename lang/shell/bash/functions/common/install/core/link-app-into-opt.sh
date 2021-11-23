#!/usr/bin/env bash

# FIXME Need to rework using dict approach.
koopa::link_app_into_opt() { # {{{1
    # """
    # Link an application into koopa opt prefix.
    # @note Updated 2021-11-17.
    # """
    koopa::assert_has_args_eq "$#" 2
    local opt_prefix source_dir target_dir
    source_dir="${1:?}"
    opt_prefix="$(koopa::opt_prefix)"
    [[ ! -d "$opt_prefix" ]] && koopa::mkdir "$opt_prefix"
    target_dir="${opt_prefix}/${2:?}"
    # This happens during installation of app packages (e.g. Python).
    [[ "$source_dir" == "$target_dir" ]] && return 0
    koopa::alert "Linking '${source_dir}' in '${target_dir}'."
    [[ ! -d "$source_dir" ]] && koopa::mkdir "$source_dir"
    [[ -d "$target_dir" ]] && koopa::sys_rm "$target_dir"
    koopa::sys_set_permissions "$opt_prefix"
    koopa::sys_ln "$source_dir" "$target_dir"
    return 0
}
