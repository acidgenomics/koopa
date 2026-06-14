# Activate Ruby gem environment.
# @note Updated 2026-06-13.
function _koopa_activate_ruby {
    $prefix = Join-Path $HOME '.gem'
    $env:GEM_HOME = $prefix
    _koopa_add_to_path_start (Join-Path $prefix 'bin')
}
