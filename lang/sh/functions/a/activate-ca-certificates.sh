#!/bin/sh

_koopa_activate_ca_certificates() {
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2023-06-12.
    #
    # @seealso
    # - REQUESTS_CA_BUNDLE
    # - SSL_CERT_FILE
    # - https://stackoverflow.com/questions/51925384/
    # """
    __kvar_prefix="$(_koopa_opt_prefix)/ca-certificates"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_prefix="$(_koopa_realpath "$__kvar_prefix")"
    __kvar_file="${__kvar_prefix}/share/ca-certificates/cacert.pem"
    if [ ! -f "$__kvar_file" ]
    then
        unset -v __kvar_file __kvar_prefix
        return 0
    fi
    export DEFAULT_CA_BUNDLE_PATH="$__kvar_prefix"
    export SSL_CERT_FILE="$__kvar_file"
    unset -v __kvar_file __kvar_prefix
    return 0
}
