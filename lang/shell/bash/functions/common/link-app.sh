#!/usr/bin/env bash

# FIXME This needs to automatically exclude 'libexec' subdirectory, such as
# for meson and ninja installers.
# FIXME Link this into '/opt/koopa/bin' instead of '/usr/local'...then we can
# have links that work on macOS too.

koopa_link_app() { # {{{1
    # """
    # Symlink application into make directory.
    # @note Updated 2022-03-30.
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
    # > koopa_link_app 'emacs' '26.3'
    # """
    local cp_args cp_source cp_target dict i include pos
    koopa_assert_has_args "$#"
    # NOTE Remove this assert once we have an ARM MacBook with Homebrew
    # configured to install into '/opt/homebrew' instead of '/usr/local'.
    koopa_assert_is_linux
    koopa_assert_has_no_envs
    declare -A dict=(
        [app_prefix]=''
        [name]=''
        [make_prefix]="$(koopa_make_prefix)"
        [version]=''
    )
    include=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-prefix='*)
                dict[app_prefix]="${1#*=}"
                shift 1
                ;;
            '--app-prefix')
                dict[app_prefix]="${2:?}"
                shift 2
                ;;
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args "$#" 1
        dict[name]="${1:?}"
    fi
    koopa_assert_is_set '--name' "${dict[name]}"
    case "${dict[name]}" in
        *'-packages' | \
        'anaconda' | \
        'aspera-connect' | \
        'bcbio-nextgen' | \
        'bcbio-nextgen-vm' | \
        'cellranger' | \
        'cloudbiolinux' | \
        'conda' | \
        'dotfiles' | \
        'ensembl-perl-api' | \
        'gcc' | \
        'gdal' | \
        'geos' | \
        'go' | \
        'lmod' | \
        'meson' | \
        'ninja' | \
        'openjdk' | \
        'openssh' | \
        'openssl' | \
        'perlbrew' | \
        'proj' | \
        'pyenv' | \
        'r-cmd-check' | \
        'r-devel' | \
        'rbenv' | \
        'rust')
            koopa_stop "Linking of '${dict[name]}' is not supported."
            ;;
    esac
    if [[ -z "${dict[app_prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            dict[version]="$(koopa_find_app_version "${dict[name]}")"
        fi
        dict[app_prefix]="$(koopa_app_prefix)/${dict[name]}/${dict[version]}"
    fi
    koopa_assert_is_dir "${dict[app_prefix]}" "${dict[make_prefix]}"
    koopa_alert "Linking '${dict[app_prefix]}' in '${dict[make_prefix]}'."
    koopa_sys_set_permissions --recursive "${dict[app_prefix]}"
    koopa_delete_broken_symlinks "${dict[app_prefix]}" "${dict[make_prefix]}"
    cp_args=('--symbolic-link')
    koopa_is_shared_install && cp_args+=('--sudo')
    if koopa_is_array_non_empty "${include[@]:-}"
    then
        # Ensure we are using relative paths in following commands.
        include=("${include[@]/^/${dict[app_prefix]}}")
        for i in "${!include[@]}"
        do
            cp_source="${dict[app_prefix]}/${include[$i]}"
            cp_target="${dict[make_prefix]}/${include[$i]}"
            koopa_cp "${cp_args[@]}" "$cp_source" "$cp_target"
        done
    else
        readarray -t include <<< "$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --prefix="${dict[app_prefix]}" \
                --sort \
                --type='d' \
        )"
        koopa_assert_is_array_non_empty "${include[@]:-}"
        cp_args+=("--target-directory=${dict[make_prefix]}")
        koopa_cp "${cp_args[@]}" "${include[@]}"
    fi
    return 0
}

koopa_link_app_into_opt() { # {{{1
    # """
    # Link an application into koopa opt prefix.
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
        [source_dir]="${1:?}"
    )
    dict[target_dir]="${dict[opt_prefix]}/${2:?}"
    [[ ! -d "${dict[opt_prefix]}" ]] && koopa_sys_mkdir "${dict[opt_prefix]}"
    [[ "${dict[source_dir]}" == "${dict[target_dir]}" ]] && return 0
    [[ ! -d "${dict[source_dir]}" ]] && koopa_sys_mkdir "${dict[source_dir]}"
    [[ -d "${dict[target_dir]}" ]] && koopa_sys_rm "${dict[target_dir]}"
    koopa_sys_ln "${dict[source_dir]}" "${dict[target_dir]}"
    return 0
}
