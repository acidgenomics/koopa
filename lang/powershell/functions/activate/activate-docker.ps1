# Activate Docker.
# @note Updated 2026-06-13.
function _koopa_activate_docker {
    _koopa_add_to_path_start (Join-Path $HOME '.docker/bin')
}
