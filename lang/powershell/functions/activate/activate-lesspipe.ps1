# Activate lesspipe.
# @note Updated 2026-06-13.
function _koopa_activate_lesspipe {
    $lesspipe = Join-Path $env:KOOPA_PREFIX 'bin/lesspipe.sh'
    if (-not (Test-Path $lesspipe)) { return }
    $env:LESS = '-R'
    $env:LESSANSIMIDCHARS = '0123456789;[?!"''#%()*+ SetMark'
    $env:LESSCHARSET = 'utf-8'
    $env:LESSCOLOR = 'yes'
    $env:LESSOPEN = "|$lesspipe %s"
    $env:LESSQUIET = '1'
    $env:LESS_ADVANCED_PREPROCESSOR = '1'
}
