# Is the operating system macOS?
# @note Updated 2026-05-01.
export def _koopa_is_macos [] -> bool {
    (sys host | get name) == "Darwin"
}
