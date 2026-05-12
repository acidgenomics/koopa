function _koopa_activate_ca_certificates
    # Activate CA certificates for OpenSSL.
    # @note Updated 2026-05-12.
    set -l prefix (_koopa_xdg_data_home)/ca-certificates
    set -l file "$prefix/cacert.pem"
    if not test -f "$file"; and not _koopa_is_macos
        set prefix /etc/ssl/certs
        set file "$prefix/ca-certificates.crt"
    end
    if not test -f "$file"
        set prefix (_koopa_opt_prefix)/ca-certificates/share/ca-certificates
        set file "$prefix/cacert.pem"
    end
    if not test -f "$file"
        return 0
    end
    set -gx AWS_CA_BUNDLE "$file"
    set -gx CURL_CA_BUNDLE "$file"
    set -gx DEFAULT_CA_BUNDLE_PATH "$prefix"
    set -gx NODE_EXTRA_CA_CERTS "$file"
    set -gx REQUESTS_CA_BUNDLE "$file"
    set -gx GIT_SSL_CAINFO "$file"
    set -gx SSL_CERT_FILE "$file"
    if not _koopa_is_macos; and test -d /etc/ssl/certs
        set -gx SSL_CERT_DIR /etc/ssl/certs
    end
end
