# Disable Copilot CLI startup updates.
function _koopa_activate_copilot_cli {
    $copilot = Join-Path $env:KOOPA_PREFIX 'bin/copilot'
    if (-not (Test-Path $copilot)) { return }
    $env:COPILOT_AUTO_UPDATE = 'false'
}
