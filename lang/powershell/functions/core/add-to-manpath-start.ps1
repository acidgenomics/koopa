# Force add directories to MANPATH start.
# @note Updated 2026-06-13.
function _koopa_add_to_manpath_start {
    param([string[]]$Dirs)
    $sep = [IO.Path]::PathSeparator
    $manpath = if ($env:MANPATH) { $env:MANPATH } else { '' }
    $parts = @($manpath -split [regex]::Escape($sep) | Where-Object { $_ })
    foreach ($dir in $Dirs) {
        if (Test-Path -Path $dir -PathType Container) {
            $parts = @($dir) + @($parts | Where-Object { $_ -ne $dir })
        }
    }
    $env:MANPATH = $parts -join $sep
}
