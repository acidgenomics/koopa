#!/bin/sh

_koopa_activate_ca_certificates() {
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2023-03-09.
    #
    # This step is currently necessary for Latch SDK on macOS.
    #
    # @seealso
    # - REQUESTS_CA_BUNDLE
    # - SSL_CERT_FILE
    # - https://stackoverflow.com/questions/51925384/
    # """
    __kvar_file="$(_koopa_opt_prefix)/ca-certificates/share/\
ca-certificates/cacert.pem"
    if [ ! -f "$__kvar_file" ]
    then
        unset -v __kvar_file
        return 0
    fi
    __kvar_file="$(_koopa_realpath "$__kvar_file")"
    export SSL_CERT_FILE="$__kvar_file"
    unset -v __kvar_file
    return 0
}
