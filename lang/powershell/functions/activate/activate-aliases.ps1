# Activate aliases for PowerShell.
# @note Updated 2026-05-01.
# PowerShell aliases cannot take parameters, so complex aliases use functions.
function _koopa_activate_aliases {
    if (-not (_koopa_is_interactive)) { return }
    $binPrefix = _koopa_bin_prefix

    # Navigation (must be functions since aliases can't take args in PS).
    function global:.. { Set-Location .. }
    function global:... { Set-Location ../.. }
    function global:.... { Set-Location ../../.. }
    function global:..... { Set-Location ../../../.. }

    # Shortcuts.
    Set-Alias -Name 'g' -Value 'git' -Scope Global -Force
    Set-Alias -Name 'k' -Value 'koopa' -Scope Global -Force
    function global:c { Clear-Host }
    function global:e { exit }
    function global:q { exit }

    # ls.
    $eza = Join-Path $binPrefix 'eza'
    if (Test-Path $eza) {
        function global:l { & $eza --classify --color=auto @args }
    } else {
        function global:l { Get-ChildItem @args }
    }
    function global:la { l -a @args }
    function global:ll { l -l @args }

    # Application-specific aliases.
    $fd = Join-Path $binPrefix 'fd'
    if (Test-Path $fd) {
        function global:fd {
            & $fd --absolute-path --ignore-case --no-ignore @args
        }
    }

    $chezmoi = Join-Path $binPrefix 'chezmoi'
    if (Test-Path $chezmoi) {
        Set-Alias -Name 'cm' -Value $chezmoi -Scope Global -Force
    }
}
