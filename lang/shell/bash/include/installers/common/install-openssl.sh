#!/usr/bin/env bash

install_openssl() { # {{{1
    # """
    # Install OpenSSL.
    # @note Updated 2022-03-28.
    #
    # @seealso
    # - https://wiki.openssl.org/index.php/Compilation_and_Installation
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/openssl@3.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='openssl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.openssl.org/source/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        "--openssldir=${dict[prefix]}"
    )
    case "${INSTALL_LINK_APP:-0}" in
        '0')
            conf_args+=('no-shared')
            ;;
        '1')
            conf_args+=('shared')
            ;;
    esac
    ./config "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
