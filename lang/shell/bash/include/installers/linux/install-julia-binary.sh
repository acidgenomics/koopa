#!/usr/bin/env bash

linux_install_julia_binary() { # {{{1
    # """
    # Install Julia (from glibc binary).
    # @note Updated 2022-03-29.
    # @seealso
    # - https://julialang.org/downloads/
    # - https://julialang.org/downloads/platform/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [name]='julia'
        [os]='linux'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[file]="${dict[name]}-${dict[version]}-${dict[os]}-${dict[arch]}.tar.gz"
    case "${dict[arch]}" in
        'x86_64')
            dict[subdir]='x64'
            ;;
        *)
            dict[subdir]="${dict[arch]}"
            ;;
    esac
    dict[url]="https://julialang-s3.julialang.org/bin/${dict[os]}/\
${dict[subdir]}/${dict[maj_min_ver]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_rm 'LICENSE.md'
    koopa_mkdir "${dict[prefix]}"
    koopa_cp . "${dict[prefix]}"
    app[julia]="${dict[prefix]}/bin/julia"
    koopa_assert_is_installed "${app[julia]}"
    koopa_configure_julia "${app[julia]}"
    return 0
}
