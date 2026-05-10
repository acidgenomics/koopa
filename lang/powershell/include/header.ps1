# PowerShell header.
# @note Updated 2026-05-01.
# @note Requires PowerShell 7+ (pwsh).

# Source function files.
Get-ChildItem -Path (Join-Path $env:KOOPA_PREFIX 'lang/powershell/functions') `
    -Recurse -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

# Save default system PATH.
if (-not $env:KOOPA_DEFAULT_SYSTEM_PATH) {
    $env:KOOPA_DEFAULT_SYSTEM_PATH = $env:PATH
}

# Activation.
function __koopa_activate_koopa {
    $koopaMinimal = $env:KOOPA_MINIMAL
    if (-not $koopaMinimal) { $koopaMinimal = '0' }

    _koopa_activate_bootstrap
    _koopa_add_to_path_start (Join-Path $env:KOOPA_PREFIX 'bin')

    if ($koopaMinimal -eq '1') { return }

    _koopa_export_env
    _koopa_activate_fzf
    _koopa_activate_zoxide

    # macOS-specific: Homebrew.
    if (_koopa_is_macos) {
        $brewPath = '/opt/homebrew/bin/brew'
        if (-not (Test-Path $brewPath)) {
            $brewPath = '/usr/local/bin/brew'
        }
        if (Test-Path $brewPath) {
            Invoke-Expression (& $brewPath shellenv)
        }
    }

    # Windows-specific: Scoop and WinGet.
    if (_koopa_is_windows) {
        _koopa_add_to_path_start @(
            (Join-Path $env:USERPROFILE 'scoop\shims'),
            (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps')
        )
    }

    # Final PATH additions.
    _koopa_add_to_path_start @(
        '/usr/local/sbin',
        '/usr/local/bin',
        (Join-Path (_koopa_xdg_config_home) 'koopa/scripts-private/bin'),
        (Join-Path $HOME '.local/bin'),
        (Join-Path $HOME '.bin'),
        (Join-Path $HOME 'bin')
    )

    _koopa_activate_aliases
    _koopa_activate_starship
}

if ($env:KOOPA_ACTIVATE -eq '1') {
    __koopa_activate_koopa
}
