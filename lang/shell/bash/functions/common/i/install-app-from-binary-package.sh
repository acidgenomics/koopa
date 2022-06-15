#!/usr/bin/env bash

koopa_install_app_from_binary_package() {
    # """
    # Install app from pre-built binary package.
    # @note Updated 2022-06-15.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [tar]="$(koopa_locate_tar)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch2)"
        [binary_prefix]='/opt/koopa'
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [name]=''
        [os_string]="$(koopa_os_string)"
        [url_stem]="$(koopa_koopa_url)/app"
        [version]=''
    )
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
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict[name]}" \
        '--version' "${dict[version]}"
    if [[ "${dict[koopa_prefix]}" != "${dict[binary_prefix]}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict[koopa_prefix]}'. Koopa must be installed at \
default '${dict[binary_prefix]}' location."
    fi
    dict[tarball_file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[tarball_url]="${dict[url_stem]}/${dict[os_string]}/${dict[arch]}/\
${dict[name]}/${dict[version]}.tar.gz"
    if ! koopa_is_url_active "${dict[tarball_url]}"
    then
        koopa_stop "No package at '${dict[tarball_url]}'."
    fi
    koopa_download "${dict[tarball_url]}" "${dict[tarball_file]}"
    "${app[tar]}" -Pxzvf "${dict[tarball_file]}"
    return 0
}
