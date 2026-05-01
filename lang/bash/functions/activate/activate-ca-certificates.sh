#!/usr/bin/env bash

_koopa_activate_ca_certificates() {
    local prefix
    prefix="$(_koopa_xdg_data_home)/ca-certificates"
    local file
    file="${prefix}/cacert.pem"
    if [[ ! -f "$file" ]] && _koopa_is_linux
    then
        prefix='/etc/ssl/certs'
        file="${prefix}/ca-certificates.crt"
    fi
    if [[ ! -f "$file" ]]
    then
        prefix="$(_koopa_opt_prefix)/ca-certificates/share/\
ca-certificates"
        file="${prefix}/cacert.pem"
    fi
    if [[ ! -f "$file" ]]
    then
        return 0
    fi
    export AWS_CA_BUNDLE="$file"
    export CURL_CA_BUNDLE="$file"
    export DEFAULT_CA_BUNDLE_PATH="$prefix"
    export NODE_EXTRA_CA_CERTS="$file"
    export REQUESTS_CA_BUNDLE="$file"
    export SSL_CERT_FILE="$file"
    if _koopa_is_linux
    then
        export SSL_CERT_DIR='/etc/ssl/certs'
    fi
    return 0
}
