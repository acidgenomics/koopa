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
    _koopa_add_to_manpath_start (Join-Path $env:KOOPA_PREFIX 'share/man')

    if ($koopaMinimal -eq '1') { return }

    _koopa_export_env
    _koopa_activate_ca_certificates
    _koopa_activate_ruby
    _koopa_activate_julia
    _koopa_activate_python
    _koopa_activate_pipx
    _koopa_activate_bat
    _koopa_activate_conda
    _koopa_activate_dircolors
    _koopa_activate_direnv
    _koopa_activate_docker
    _koopa_activate_fzf
    _koopa_activate_lesspipe
    _koopa_activate_pyright
    _koopa_activate_ripgrep
    _koopa_activate_tealdeer
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

    _koopa_activate_micromamba

    # Final PATH additions.
    _koopa_add_to_path_start @(
        '/usr/local/sbin',
        '/usr/local/bin',
        (Join-Path (_koopa_xdg_config_home) 'koopa/scripts-private/bin'),
        (Join-Path $HOME '.local/bin'),
        (Join-Path $HOME '.bin'),
        (Join-Path $HOME 'bin')
    )
    _koopa_add_to_manpath_start @('/usr/local/man', '/usr/local/share/man')
    _koopa_add_to_manpath_end '/usr/share/man'
    _koopa_activate_difftastic
    _koopa_activate_aliases
    _koopa_activate_starship
    _koopa_activate_color_mode_sync
}

if ($env:KOOPA_ACTIVATE -eq '1') {
    __koopa_activate_koopa
    # Dot-call at top level so completion files' helper functions (e.g. cobra-
    # generated __op_debug) land in the session scope rather than the local
    # scope of __koopa_activate_koopa where they would evaporate on return.
    $koopaMinimal = $env:KOOPA_MINIMAL
    if (-not $koopaMinimal) { $koopaMinimal = '0' }
    if ($koopaMinimal -ne '1') { . _koopa_activate_completions }
}
