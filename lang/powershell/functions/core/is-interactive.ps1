# Is the current shell interactive?
# @note Updated 2026-05-01.
function _koopa_is_interactive {
    return [Environment]::UserInteractive
}
