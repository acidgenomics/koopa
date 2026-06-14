# Activate dircolors (LS_COLORS) for PowerShell.
# @note Updated 2026-06-13.
function _koopa_activate_dircolors {
    $dircolors = Join-Path $env:KOOPA_PREFIX 'bin/gdircolors'
    if (-not (Test-Path $dircolors)) { return }
    $prefix = Join-Path $env:XDG_CONFIG_HOME 'dircolors'
    if (-not (Test-Path $prefix -PathType Container)) { return }
    $confFile = Join-Path $prefix "dircolors-$env:KOOPA_COLOR_MODE"
    if (-not (Test-Path $confFile)) { return }
    # gdircolors only emits sh/csh; extract the LS_COLORS value directly.
    $out = (& $dircolors --sh $confFile) -join "`n"
    if ($out -match "LS_COLORS='(.*)';") {
        $env:LS_COLORS = $Matches[1]
    }
}
