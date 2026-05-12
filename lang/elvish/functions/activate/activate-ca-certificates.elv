# Activate CA certificates for OpenSSL.
# @note Updated 2026-05-12.
use path
use platform

fn activate-ca-certificates {
    var prefix = (xdg-data-home)'/ca-certificates'
    var file = $prefix'/cacert.pem'
    if (and (not (path:is-regular &follow-symlink $file)) (not (is-macos))) {
        set prefix = '/etc/ssl/certs'
        set file = $prefix'/ca-certificates.crt'
    }
    if (not (path:is-regular &follow-symlink $file)) {
        set prefix = (opt-prefix)'/ca-certificates/share/ca-certificates'
        set file = $prefix'/cacert.pem'
    }
    if (not (path:is-regular &follow-symlink $file)) {
        return
    }
    set-env AWS_CA_BUNDLE $file
    set-env CURL_CA_BUNDLE $file
    set-env DEFAULT_CA_BUNDLE_PATH $prefix
    set-env NODE_EXTRA_CA_CERTS $file
    set-env REQUESTS_CA_BUNDLE $file
    set-env GIT_SSL_CAINFO $file
    set-env SSL_CERT_FILE $file
    if (and (not (is-macos)) (path:is-dir '/etc/ssl/certs')) {
        set-env SSL_CERT_DIR '/etc/ssl/certs'
    }
}
