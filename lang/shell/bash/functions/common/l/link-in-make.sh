#!/usr/bin/env bash

koopa_link_in_make() {
    # """
    # Symlink application into make directory.
    # @note Updated 2022-04-08.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with 'koopa_sys_set_permissions'.
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
    # > koopa_link_in_make --prefix='/opt/koopa/app/autoconf/2.71'
    # > koopa_link_in_make \
    # >     --include='bin/conda' \
    # >     --prefix='/opt/koopa/app/conda/4.11.0'
    # """
    local cp_args dict exclude_arr files_arr find_args i include_arr
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_prefix]=''
        [make_prefix]="$(koopa_make_prefix)"
    )
    exclude_arr=('libexec')
    include_arr=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--exclude='*)
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--include='*)
                include_arr+=("${1#*=}")
                shift 1
                ;;
            '--include')
                include_arr+=("${2:?}")
                shift 2
                ;;
            '--prefix='*)
                dict[app_prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[app_prefix]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--prefix' "${dict[app_prefix]}"
    koopa_assert_is_dir "${dict[app_prefix]}" "${dict[make_prefix]}"
    dict[app_prefix]="$(koopa_realpath "${dict[app_prefix]}")"
    if koopa_is_array_non_empty "${include_arr[@]:-}"
    then
        for i in "${!include_arr[@]}"
        do
            files_arr[i]="${dict[app_prefix]}/${include_arr[i]}"
        done
    else
        find_args=(
            '--max-depth=1'
            '--min-depth=1'
            "--prefix=${dict[app_prefix]}"
            '--sort'
            '--type=d'
        )
        if koopa_is_array_non_empty "${exclude_arr[@]:-}"
        then
            for i in "${!exclude_arr[@]}"
            do
                find_args+=("--exclude=${exclude_arr[i]}")
            done
        fi
        readarray -t files_arr <<< "$(koopa_find "${find_args[@]}")"
    fi
    if koopa_is_array_empty "${files_arr[@]:-}"
    then
        koopa_stop "No files from '${dict[app_prefix]}' to link \
into '${dict[make_prefix]}'."
    fi
    koopa_assert_is_existing "${files_arr[@]}"
    koopa_alert "Linking '${dict[app_prefix]}' in '${dict[make_prefix]}'."
    koopa_sys_set_permissions --recursive "${dict[app_prefix]}"
    koopa_delete_broken_symlinks "${dict[app_prefix]}"
    cp_args=('--symbolic-link')
    koopa_is_shared_install && cp_args+=('--sudo')
    cp_args+=(
        "--target-directory=${dict[make_prefix]}"
        "${files_arr[@]}"
    )
    koopa_cp "${cp_args[@]}"
    return 0
}
