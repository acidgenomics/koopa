#!/usr/bin/env bash

koopa::link_app() { # {{{1
    # """
    # Symlink application into make directory.
    # @note Updated 2021-11-16.
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
    local cp_args dict i include pos
    koopa::assert_has_args "$#"
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
    koopa::link_into_opt "${dict[app_prefix]}" "${dict[name]}"
    koopa::is_macos && return 0
    koopa::alert "Linking '${dict[app_prefix]}' in '${dict[make_prefix]}'."
    koopa::sys_set_permissions --recursive "${dict[app_prefix]}"
    koopa::delete_broken_symlinks "${dict[app_prefix]}" "${dict[make_prefix]}"
    if ! koopa::is_array_non_empty "${include[@]:-}"
    then
        include=("${include[@]/^/${dict[app_prefix]}}")
        for i in "${!include[@]}"
        do
            include[$i]="${dict[app_prefix]}/${include[$i]}"
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
    fi
    koopa::assert_is_array_non_empty "${include[@]:-}"
    # Copy as symbolic links.
    cp_args=(
        '--symbolic-link'
        "--target-directory=${dict[make_prefix]}"
    )
    koopa::is_shared_install && cp_args+=('--sudo')
    koopa::cp "${cp_args[@]}" "${include[@]}"
    return 0
}
