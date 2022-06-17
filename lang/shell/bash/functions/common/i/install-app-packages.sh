#!/usr/bin/env bash

# FIXME Rework and simplify this...

koopa_install_app_packages() {
    # """
    # Install application packages.
    # @note Updated 2022-06-17.
    # """
    local app name name_fancy pos
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [reinstall]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            # Internally defined arguments -------------------------------------
            '--prefix='* | '--prefix' | \
            '--version='* | '--version' | \
            '--no-prefix-check' | \
            '--prefix-check')
                koopa_invalid_arg "$1"
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict[name]}"
    app[cmd]="$("koopa_locate_${dict[name]}")"
    koopa_assert_is_installed "${app[cmd]}"
    # Configure the language.
    dict[configure_fun]="koopa_configure_${dict[name]}"
    "${dict[configure_fun]}"
    koopa_assert_is_function "${dict[configure_fun]}"
    # Detect the linked package prefix, defined in 'opt'.
    dict[prefix_fun]="koopa_${dict[name]}_packages_prefix"
    koopa_assert_is_function "${dict[prefix_fun]}"
    dict[prefix]="$("${dict[prefix_fun]}")"
    if [[ -d "${dict[prefix]}" ]]
    then
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        koopa_rm "${dict[prefix]}"
    fi
    dict[version]="$(koopa_get_version "${app[cmd]}")"
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    koopa_install_app \
        --name-fancy="${dict[name_fancy]} packages" \
        --name="${dict[name]}-packages" \
        --no-prefix-check \
        --prefix="${dict[prefix]}" \
        --version="${dict[maj_min_ver]}" \
        "$@"
    return 0
}
