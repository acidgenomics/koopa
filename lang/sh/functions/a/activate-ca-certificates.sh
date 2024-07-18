#!/bin/sh

_koopa_activate_ca_certificates() {
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2024-07-18.
    #
    # @seealso
    # - https://stackoverflow.com/questions/51925384/
    # - https://curl.se/docs/caextract.html
    # """
    [ -n "${DEFAULT_CA_BUNDLE_PATH:-}" ] && return 0
    [ -n "${REQUESTS_CA_BUNDLE:-}" ] && return 0
    [ -n "${SSL_CERT_FILE:-}" ] && return 0
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
    export REQUESTS_CA_BUNDLE="$__kvar_file"
    export SSL_CERT_FILE="$__kvar_file"
    unset -v __kvar_file __kvar_prefix
    return 0
}
