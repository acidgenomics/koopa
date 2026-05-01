# Is the operating system macOS?
# @note Updated 2026-05-01.
use platform
fn is-macos {
    eq $platform:os 'darwin'
}
