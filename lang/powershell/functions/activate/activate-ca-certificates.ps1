# Activate CA certificates for OpenSSL.
# @note Updated 2026-05-12.
function _koopa_activate_ca_certificates {
    $prefix = Join-Path (_koopa_xdg_data_home) 'ca-certificates'
    $file = Join-Path $prefix 'cacert.pem'
    if ((-not (Test-Path $file)) -and (-not (_koopa_is_macos))) {
        $prefix = '/etc/ssl/certs'
        $file = Join-Path $prefix 'ca-certificates.crt'
    }
    if (-not (Test-Path $file)) {
        $prefix = Join-Path (_koopa_opt_prefix) 'ca-certificates/share/ca-certificates'
        $file = Join-Path $prefix 'cacert.pem'
    }
    if (-not (Test-Path $file)) {
        return
    }
    $env:AWS_CA_BUNDLE = $file
    $env:CURL_CA_BUNDLE = $file
    $env:DEFAULT_CA_BUNDLE_PATH = $prefix
    $env:NODE_EXTRA_CA_CERTS = $file
    $env:REQUESTS_CA_BUNDLE = $file
    $env:GIT_SSL_CAINFO = $file
    $env:SSL_CERT_FILE = $file
    if ((-not (_koopa_is_macos)) -and (Test-Path '/etc/ssl/certs' -PathType Container)) {
        $env:SSL_CERT_DIR = '/etc/ssl/certs'
    }
}
