# Activate CA certificates for OpenSSL.
# @note Updated 2026-05-12.
export def _koopa_activate_ca_certificates [] {
    mut prefix = $"((_koopa_xdg_data_home))/ca-certificates"
    mut file = $"($prefix)/cacert.pem"
    if not ($file | path exists) and not (_koopa_is_macos) {
        $prefix = "/etc/ssl/certs"
        $file = $"($prefix)/ca-certificates.crt"
    }
    if not ($file | path exists) {
        $prefix = $"((_koopa_opt_prefix))/ca-certificates/share/ca-certificates"
        $file = $"($prefix)/cacert.pem"
    }
    if not ($file | path exists) {
        return
    }
    $env.AWS_CA_BUNDLE = $file
    $env.CURL_CA_BUNDLE = $file
    $env.DEFAULT_CA_BUNDLE_PATH = $prefix
    $env.NODE_EXTRA_CA_CERTS = $file
    $env.REQUESTS_CA_BUNDLE = $file
    $env.GIT_SSL_CAINFO = $file
    $env.SSL_CERT_FILE = $file
    if not (_koopa_is_macos) and ("/etc/ssl/certs" | path exists) {
        $env.SSL_CERT_DIR = "/etc/ssl/certs"
    }
}
