#!/usr/bin/env bash

main() {
    # """
    # Install Mozilla CA certificate store.
    # @note Updated 2023-04-06.
    #
    # Consider exporting 'SSL_CERT_FILE' as a global variable in shell session.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     ca-certificates.rb
    # - https://gist.github.com/fnichol/867550#the-manual-way-boring
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="cacert-${dict['version']}.pem"
    dict['url']="https://curl.se/ca/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_cp \
        "${dict['file']}" \
        "${dict['prefix']}/share/ca-certificates/cacert.pem"
    return 0
}
