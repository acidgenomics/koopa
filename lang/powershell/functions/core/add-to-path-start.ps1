# Force add directories to PATH start.
# @note Updated 2026-05-01.
function _koopa_add_to_path_start {
    param([string[]]$Dirs)
    $sep = [IO.Path]::PathSeparator
    $paths = @($env:PATH -split [regex]::Escape($sep) | Where-Object { $_ })
    foreach ($dir in $Dirs) {
        if (Test-Path -Path $dir -PathType Container) {
            $paths = @($dir) + @($paths | Where-Object { $_ -ne $dir })
        }
    }
    $env:PATH = $paths -join $sep
}
