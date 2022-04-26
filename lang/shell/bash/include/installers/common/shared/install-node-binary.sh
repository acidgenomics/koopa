#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Node.js binary.
    # @note Updated 2022-04-19.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa_arch2)" # e.g. 'amd64'.
        [name]='node'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict[platform]='darwin'
        dict[compress_ext]='gz'
    elif koopa_is_linux
    then
        dict[platform]='linux'
        dict[compress_ext]='xz'
    else
        koopa_stop 'Unsupported platform.'
    fi
    case "${dict[arch]}" in
        'amd64')
            dict[arch]='x64'
            ;;
        'arm64')
            ;;
        *)
            koopa_stop "Unsupported architecture: '${dict[arch]}'."
            ;;
    esac
    dict[file]="${dict[name]}-v${dict[version]}-${dict[platform]}-\
${dict[arch]}.tar.${dict[compress_ext]}"
    dict[url]="https://nodejs.org/dist/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cp \
        "${dict[name]}-v${dict[version]}-${dict[platform]}-${dict[arch]}" \
        "${dict[prefix]}"
    return 0
}
