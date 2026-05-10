#!/bin/sh

_koopa_activate_ca_certificates() {
    # """
    # Activate CA certificates for OpenSSL.
    # @note Updated 2026-01-22.
    #
    # @seealso
    # - https://stackoverflow.com/questions/51925384/
    # - https://curl.se/docs/caextract.html
    # - https://stat.ethz.ch/R-manual/R-devel/library/utils/html/
    #   download.file.html
    # """
    __kvar_prefix="$(_koopa_xdg_data_home)/ca-certificates"
    __kvar_file="${__kvar_prefix}/cacert.pem"
    if [ ! -f "$__kvar_file" ] && _koopa_is_linux
    then
        __kvar_prefix='/etc/ssl/certs'
        __kvar_file="${__kvar_prefix}/ca-certificates.crt"
    fi
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
    export CURL_CA_BUNDLE="$__kvar_file"
    export DEFAULT_CA_BUNDLE_PATH="$__kvar_prefix"
    export NODE_EXTRA_CA_CERTS="$__kvar_file"
    export REQUESTS_CA_BUNDLE="$__kvar_file"
    export SSL_CERT_FILE="$__kvar_file"
    if _koopa_is_linux
    then
        export SSL_CERT_DIR='/etc/ssl/certs'
    fi
    unset -v __kvar_file __kvar_prefix
    return 0
}
