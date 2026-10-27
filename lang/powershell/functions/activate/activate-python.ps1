# Activate Python environment variables.
# @note Updated 2026-10-23.
function _koopa_activate_python {
    if (-not $env:PIP_REQUIRE_VIRTUALENV) {
        $env:PIP_REQUIRE_VIRTUALENV = 'true'
    }
    if (-not $env:PYTHONPYCACHEPREFIX) {
        $cacheHome = $env:XDG_CACHE_HOME
        if (-not $cacheHome) {
            $cacheHome = Join-Path $HOME '.cache'
        }
        $env:PYTHONPYCACHEPREFIX = Join-Path $cacheHome 'python'
    }
    if (-not $env:PYTHONSTARTUP) {
        $startupFile = Join-Path $HOME '.pyrc'
        if (Test-Path $startupFile) {
            $env:PYTHONSTARTUP = $startupFile
        }
    }
    if (-not $env:PYTHONWARNINGS) {
        $env:PYTHONWARNINGS = 'ignore::SyntaxWarning'
    }
    if (-not $env:VIRTUAL_ENV_DISABLE_PROMPT) {
        $env:VIRTUAL_ENV_DISABLE_PROMPT = '1'
    }
}
