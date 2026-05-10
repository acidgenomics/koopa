# Are all of the requested programs installed?
# @note Updated 2026-05-01.
function _koopa_is_installed {
    param([string[]]$Cmds)
    foreach ($cmd in $Cmds) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            return $false
        }
    }
    return $true
}
