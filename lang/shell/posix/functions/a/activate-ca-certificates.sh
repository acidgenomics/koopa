#!/bin/sh

_koopa_activate_ca_certificates() {
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2022-10-05.
    #
    # This step is currently necessary for Latch SDK on macOS.
    #
    # @seealso
    # - REQUESTS_CA_BUNDLE
    # - SSL_CERT_FILE
    # - https://stackoverflow.com/questions/51925384/
    # """
    local prefix ssl_cert_file
    prefix="$(koopa_opt_prefix)/ca-certificates"
    [ -d "$prefix" ] || return 0
    prefix="$(koopa_realpath "$prefix")"
    ssl_cert_file="${prefix}/share/ca-certificates/cacert.pem"
    [ -f "$ssl_cert_file" ] || return 0
    export SSL_CERT_FILE="$ssl_cert_file"
    return 0
}
