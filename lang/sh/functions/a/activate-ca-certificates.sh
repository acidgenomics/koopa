#!/bin/sh

# FIXME Add fallback support for system certs:
# /etc/ssl/certs/ca-certificates.crt

_koopa_activate_ca_certificates() {
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2024-12-04.
    #
    # @seealso
    # - https://stackoverflow.com/questions/51925384/
    # - https://curl.se/docs/caextract.html
    # """
    [ -n "${AWS_CA_BUNDLE:-}" ] && return 0
    [ -n "${DEFAULT_CA_BUNDLE_PATH:-}" ] && return 0
    [ -n "${NODE_EXTRA_CA_CERTS:-}" ] && return 0
    [ -n "${REQUESTS_CA_BUNDLE:-}" ] && return 0
    [ -n "${SSL_CERT_FILE:-}" ] && return 0
    __kvar_prefix="$(_koopa_xdg_data_home)/ca-certificates"
    __kvar_file="${__kvar_prefix}/cacert.pem"
    if [ ! -f "$__kvar_file" ]
    then
        __kvar_prefix="$(_koopa_opt_prefix)/ca-certificates/share/\
ca-certificates"
        __kvar_file="${__kvar_prefix}/cacert.pem"
    fi
    if [ ! -f "$__kvar_file" ]
    then
        unset -v __kvar_file __kvar_prefix
        return 0
    fi
    export AWS_CA_BUNDLE="$__kvar_file"
    export DEFAULT_CA_BUNDLE_PATH="$__kvar_prefix"
    export NODE_EXTRA_CA_CERTS="$__kvar_file"
    export REQUESTS_CA_BUNDLE="$__kvar_file"
    export SSL_CERT_FILE="$__kvar_file"
    unset -v __kvar_file __kvar_prefix
    return 0
}
