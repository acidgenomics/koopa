function _koopa_is_macos
    # Is the operating system macOS?
    # @note Updated 2026-05-01.
    test (uname -s) = Darwin
end
