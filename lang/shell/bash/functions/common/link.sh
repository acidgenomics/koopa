#!/usr/bin/env bash

__koopa_link_in_dir() { # {{{1
    # """
    # Symlink multiple programs in a directory.
    # @note Updated 2022-04-07.
    #
    # @usage
    # > __koopa_link_in_dir \
    # >     --prefix=PREFIX \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > __koopa_link_in_dir \
    # >     --prefix="$(koopa_bin_prefix) \
    # >     '/usr/local/bin/emacs' 'emacs' \
    # >     '/usr/local/bin/vim' 'vim'
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_ge "$#" 2
    koopa_assert_is_set '--prefix' "${dict[prefix]}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    while [[ "$#" -ge 2 ]]
    do
        local dict2
        declare -A dict2=(
            [source_file]="${1:?}"
            [target_name]="${2:?}"
        )
        # This is problematic when linking from Homebrew 'opt/'.
        # > koopa_assert_is_existing "${dict2[source_file]}"
        # > dict2[source_file]="$(koopa_realpath "${dict2[source_file]}")"
        dict2[target_file]="${dict[prefix]}/${dict2[target_name]}"
        koopa_sys_ln "${dict2[source_file]}" "${dict2[target_file]}"
        shift 2
    done
    return 0
}

__koopa_unlink_in_dir() { # {{{1
    # """
    # Unlink multiple symlinks in a directory.
    # @note Updated 2022-04-06.
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_set '--prefix' "${dict[prefix]}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    names=("$@")
    files=()
    for i in "${!names[@]}"
    do
        files+=("${dict[prefix]}/${names[$i]}")
    done
    koopa_assert_is_file "${files[@]}"
    koopa_rm "${files[@]}"
    return 0
}

koopa_link_in_bin() { # {{{1
    # """
    # Link a program in koopa 'bin/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage
    # > koopa_link_in_bin \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_bin \
    # >     '/usr/local/bin/emacs' 'emacs' \
    # >     '/usr/local/bin/vim' 'vim'
    # """
    __koopa_link_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}

koopa_link_in_make() { # {{{1
    # """
    # Symlink application into make directory.
    # @note Updated 2022-04-06.
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
        [homebrew_prefix]="$(koopa_homebrew_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
    )
    if [[ "${dict[homebrew_prefix]}" == "${dict[make_prefix]}" ]]
    then
        koopa_stop "Homebrew is configured in '${dict[make_prefix]}'."
    fi
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
    koopa_delete_broken_symlinks "${dict[app_prefix]}" "${dict[make_prefix]}"
    cp_args=('--symbolic-link')
    koopa_is_shared_install && cp_args+=('--sudo')
    cp_args+=(
        "--target-directory=${dict[make_prefix]}"
        "${files_arr[@]}"
    )
    koopa_cp "${cp_args[@]}"
    return 0
}

koopa_link_in_opt() { # {{{1
    # """
    # Link an application in koopa 'opt/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage
    # > koopa_link_in_opt \
    # >     SOURCE_DIR_1 TARGET_NAME_1 \
    # >     SOURCE_DIR_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_opt \
    # >     '/opt/koopa/app/python/3.10.0' 'python' \
    # >     '/opt/koopa/app/r/3.4.0' 'r'
    # """
    __koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}

koopa_link_in_sbin() { # {{{1
    # """
    # Link a program in koopa 'sbin/ directory.
    # @note Updated 2022-04-06.
    # 
    # @usage
    # > koopa_link_in_sbin \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_sbin \
    # >     '/Library/TeX/texbin/tlmgr' 'tlmgr'
    # """
    __koopa_link_in_dir --prefix="$(koopa_sbin_prefix)" "$@"
}

koopa_unlink_in_bin() { # {{{1
    # """
    # Unlink a program symlinked in koopa 'bin/ directory.
    # @note Updated 2022-04-06.
    #
    # @usage koopa_unlink_in_bin NAME...
    #
    # @examples
    # > koopa_unlink_in_bin 'R' 'Rscript'
    # """
    __koopa_unlink_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}

koopa_unlink_in_make() { # {{{1
    # """
    # Unlink a program symlinked in koopa 'make/' directory.
    # @note Updated 2022-04-07.
    #
    # @examples
    # > koopa_unlink_in_make '/opt/koopa/app/autoconf'
    #
    # Unlink all koopa apps with:
    # > koopa_unlink_in_make '/opt/koopa/app'
    # """
    local app_prefix dict files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_prefix]=''
        [homebrew_prefix]="$(koopa_homebrew_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
    )
    if [[ "${dict[homebrew_prefix]}" == "${dict[make_prefix]}" ]]
    then
        koopa_stop "Homebrew is configured in '${dict[make_prefix]}'."
    fi
    koopa_assert_is_dir "${dict[make_prefix]}"
    for app_prefix in "$@"
    do
        dict[app_prefix]="$app_prefix"
        koopa_assert_is_dir "${dict[app_prefix]}"
        dict[app_prefix]="$(koopa_realpath "${dict[app_prefix]}")"
        readarray -t files <<< "$( \
            koopa_find_symlinks \
                --source-prefix="${dict[app_prefix]}" \
                --target-prefix="${dict[make_prefix]}" \
                --verbose \
        )"
        if koopa_is_array_empty "${files[@]:-}"
        then
            koopa_stop "No files from '${dict[app_prefix]}' detected."
        fi
        koopa_alert "$(koopa_ngettext \
            --prefix='Unlinking ' \
            --num="${#files[@]}" \
            --msg1='file' \
            --msg2='files' \
            --suffix=" from '${dict[app_prefix]}' in '${dict[make_prefix]}'." \
        )"
        for file in "${files[@]}"
        do
            koopa_rm "$file"
        done
    done
    return 0
}

koopa_unlink_in_opt() { # {{{1
    # """
    # Unlink a program symlinked in koopa 'opt/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage koopa_unlink_in_opt NAME...
    #
    # @examples
    # > koopa_unlink_in_opt 'python' 'r'
    # """
    __koopa_unlink_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}

koopa_unlink_in_sbin() { # {{{1
    # """
    # Unlink a program symlinked in koopa 'sbin/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage koopa_unlink_in_sbin NAME...
    #
    # @examples
    # > koopa_unlink_in_sbin 'tlmgr'
    # """
    __koopa_unlink_in_dir --prefix="$(koopa_sbin_prefix)" "$@"
}
