function _koopa_is_installed
    # Are all of the requested programs installed?
    # @note Updated 2026-05-01.
    for cmd in $argv
        type -q "$cmd"; or return 1
    end
    return 0
end
