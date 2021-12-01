#!/usr/bin/env bash

koopa:::linux_install_julia_binary() { # {{{1
    # """
    # Install Julia (from glibc binary).
    # @note Updated 2021-12-01.
    # @seealso
    # - https://julialang.org/downloads/
    # - https://julialang.org/downloads/platform/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [name]='julia'
        [os]='linux'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa::major_minor_version "${dict[version]}")"
    file="${dict[name]}-${dict[version]}-${dict[os]}-${dict[arch]}.tar.gz"
    case "${dict[arch]}" in
        'x86'*)
            dict[subdir]='x64'
            ;;
        *)
            dict[subdir]="${dict[arch]}"
            ;;
    esac
    dict[url]="https://julialang-s3.julialang.org/bin/${dict[os]}/\
${dict[subdir]}/${dict[maj_min_ver]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    koopa::rm 'LICENSE.md'
    koopa::mkdir "${dict[prefix]}"
    koopa::cp . "${dict[prefix]}"
    return 0
}
