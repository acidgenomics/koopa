function _koopa_activate_lig {
    $lig = Join-Path $env:KOOPA_PREFIX 'bin/lig'
    if (-not (Test-Path -LiteralPath $lig -PathType Leaf)) { return }
    if ($env:LIG_DISABLE) { return }
    if ($Host.Name -ne 'ConsoleHost' -or
        [Console]::IsInputRedirected -or [Console]::IsOutputRedirected) { return }

    $cacheFile = Join-Path $env:XDG_CACHE_HOME 'koopa/shell-init/lig-powershell-pre.ps1'
    if (
        (-not (Test-Path -LiteralPath $cacheFile)) -or
        ((Get-Item -LiteralPath $lig).LastWriteTime -gt
            (Get-Item -LiteralPath $cacheFile).LastWriteTime)
    ) {
        $cacheDir = Split-Path -Parent $cacheFile
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
        $tmpFile = "$cacheFile.$PID"
        $init = & $lig init powershell pre
        if ($LASTEXITCODE -ne 0) {
            Remove-Item -LiteralPath $tmpFile -ErrorAction SilentlyContinue
            throw "lig init powershell pre failed with exit code $LASTEXITCODE"
        }
        Set-Content -LiteralPath $tmpFile -Value $init -Encoding utf8NoBOM
        if (-not (Test-Path -LiteralPath $tmpFile) -or
            (Get-Item -LiteralPath $tmpFile).Length -eq 0) {
            Remove-Item -LiteralPath $tmpFile -ErrorAction SilentlyContinue
            throw 'lig init powershell pre returned no shell initialization code'
        }
        Move-Item -LiteralPath $tmpFile -Destination $cacheFile -Force
    }

    . $cacheFile
}
