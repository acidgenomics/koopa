# Koopa activation for PowerShell.
# @note Updated 2026-05-01.
#
# Usage:
#     Add to your PowerShell profile ($PROFILE):
#         . /path/to/koopa/activate.ps1

if ($env:KOOPA_SKIP -eq '1') { return }

if ($env:KOOPA_FORCE -ne '1') {
    if (-not [Environment]::UserInteractive) { return }
}

if ($env:KOOPA_PREFIX) {
    $env:KOOPA_SUBSHELL = '1'
}

$env:KOOPA_PREFIX = Split-Path -Parent $PSCommandPath
$env:KOOPA_ACTIVATE = '1'

$koopaHeader = Join-Path $env:KOOPA_PREFIX 'lang/powershell/include/header.ps1'
if (Test-Path $koopaHeader) {
    . $koopaHeader
}

Remove-Item Env:\KOOPA_ACTIVATE -ErrorAction SilentlyContinue
