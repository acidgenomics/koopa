# Force add directories to PATH end.
# @note Updated 2026-05-01.
function _koopa_add_to_path_end {
    param([string[]]$Dirs)
    $sep = [IO.Path]::PathSeparator
    $paths = @($env:PATH -split [regex]::Escape($sep) | Where-Object { $_ })
    foreach ($dir in $Dirs) {
        if (Test-Path -Path $dir -PathType Container) {
            $paths = @($paths | Where-Object { $_ -ne $dir }) + @($dir)
        }
    }
    $env:PATH = $paths -join $sep
}
