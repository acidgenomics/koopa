#!/usr/bin/env bash

main() {
    # """
    # Install Google Cloud SDK.
    # @note Updated 2023-03-20.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install
    # - https://github.com/Homebrew/homebrew-cask/blob/master/
    #     Casks/google-cloud-sdk.rb
    # """
    local dict
    koopa_activate_app --build-only 'python3.10'
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_linux
    then
        dict['os']='linux'
    elif koopa_is_macos
    then
        dict['os']='darwin'
    fi
    case "${dict['arch']}" in
        'aarch64' | 'arm64')
            dict['arch2']='arm'
            ;;
        *)
            dict['arch2']="${dict['arch']}"
            ;;
    esac
    dict['file']="google-cloud-cli-${dict['version']}-${dict['os']}-\
${dict['arch2']}.tar.gz"
    dict['url']="https://dl.google.com/dl/cloudsdk/channels/rapid/\
downloads/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp 'google-cloud-sdk' "${dict['prefix']}"
    return 0
}
