# Disable the Antigravity CLI (agy) background auto-updater.
# agy accepts 'true', not '1'.
function Activate-AntigravityCli {
    $env:AGY_CLI_DISABLE_AUTO_UPDATE = "true"
}
