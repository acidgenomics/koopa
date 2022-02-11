#!/usr/bin/env bash

koopa::link_app() { # {{{1
    # """
    # Symlink application into make directory.
    # @note Updated 2022-02-03.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with 'koopa::sys_set_permissions'.
    #
    # Note that Debian symlinks 'man' to 'share/man', which is non-standard.
    # This is currently corrected in 'install-debian-base', but top-level
    # symlink checks may need to be added here in a future update.
    #
    # @section cp arguments:
    # * -f, --force
    # * -R, -r, --recursive
    # * -s, --symbolic-link
    #
    # @examples
    # > koopa::link_app 'emacs' '26.3'
    # """
    local cp_args cp_source cp_target dict i include pos
    koopa::assert_has_args "$#"
    # NOTE Remove this assert once we have an ARM MacBook with Homebrew
    # configured to install into '/opt/homebrew' instead of '/usr/local'.
    koopa::assert_is_linux
    koopa::assert_has_no_envs
    declare -A dict=(
        [make_prefix]="$(koopa::make_prefix)"
        [version]=''
    )
    include=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--include='*)
                include+=("${1#*=}")
                shift 1
                ;;
            '--include')
                include+=("${2:?}")
                shift 2
                ;;
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_le "$#" 1
    if [[ -n "${1:-}" ]]
    then
        dict[name]="${1:?}"
    fi
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa::find_app_version "${dict[name]}")"
    fi
    dict[app_prefix]="$(koopa::app_prefix)/${dict[name]}/${dict[version]}"
    koopa::assert_is_dir "${dict[app_prefix]}" "${dict[make_prefix]}"
    koopa::alert "Linking '${dict[app_prefix]}' in '${dict[make_prefix]}'."
    koopa::sys_set_permissions --recursive "${dict[app_prefix]}"
    koopa::delete_broken_symlinks "${dict[app_prefix]}" "${dict[make_prefix]}"
    cp_args=('--symbolic-link')
    koopa::is_shared_install && cp_args+=('--sudo')
    if koopa::is_array_non_empty "${include[@]:-}"
    then
        # Ensure we are using relative paths in following commands.
        include=("${include[@]/^/${dict[app_prefix]}}")
        for i in "${!include[@]}"
        do
            cp_source="${dict[app_prefix]}/${include[$i]}"
            cp_target="${dict[make_prefix]}/${include[$i]}"
            koopa::cp "${cp_args[@]}" "$cp_source" "$cp_target"
        done
    else
        readarray -t include <<< "$( \
            koopa::find \
                --max-depth=1 \
                --min-depth=1 \
                --prefix="${dict[app_prefix]}" \
                --sort \
                --type='d' \
        )"
        koopa::assert_is_array_non_empty "${include[@]:-}"
        cp_args+=("--target-directory=${dict[make_prefix]}")
        koopa::cp "${cp_args[@]}" "${include[@]}"
    fi
    return 0
}

koopa::link_app_into_opt() { # {{{1
    # """
    # Link an application into koopa opt prefix.
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 2
    declare -A dict=(
        [opt_prefix]="$(koopa::opt_prefix)"
        [source_dir]="${1:?}"
    )
    dict[target_dir]="${dict[opt_prefix]}/${2:?}"
    [[ ! -d "${dict[opt_prefix]}" ]] && koopa::sys_mkdir "${dict[opt_prefix]}"
    [[ "${dict[source_dir]}" == "${dict[target_dir]}" ]] && return 0
    [[ ! -d "${dict[source_dir]}" ]] && koopa::sys_mkdir "${dict[source_dir]}"
    [[ -d "${dict[target_dir]}" ]] && koopa::sys_rm "${dict[target_dir]}"
    koopa::sys_ln "${dict[source_dir]}" "${dict[target_dir]}"
    return 0
}
