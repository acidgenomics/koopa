#!/usr/bin/env bash

main() {
    # """
    # Install Mozilla CA certificate store.
    # @note Updated 2022-07-22.
    #
    # Consider exporting 'SSL_CERT_FILE' as a global variable in shell session.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     ca-certificates.rb
    # - https://gist.github.com/fnichol/867550#the-manual-way-boring
    # """
    local dict
    local -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="cacert-${dict['version']}.pem"
    dict['url']="https://curl.se/ca/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_cp \
        "${dict['file']}" \
        "${dict['prefix']}/share/ca-certificates/cacert.pem"
    return 0
}
