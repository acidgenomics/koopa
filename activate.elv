# Koopa activation for Elvish.
# @note Updated 2026-05-01.
#
# Usage:
#     Add to your ~/.config/elvish/rc.elv:
#         use /path/to/koopa/activate

use path

if (has-env KOOPA_SKIP) {
    if (eq $E:KOOPA_SKIP '1') {
        nop
    }
} else {
    if (and (not (has-env KOOPA_FORCE)) (not (bool ?(tty </dev/tty >/dev/null 2>&1)))) {
        nop
    } else {
        if (has-env KOOPA_PREFIX) {
            set-env KOOPA_SUBSHELL '1'
        }

        var script-path~ = { put (src)[name] }
        set-env KOOPA_PREFIX (path:dir (script-path))
        set-env KOOPA_ACTIVATE '1'

        var header = $E:KOOPA_PREFIX'/lang/elvish/include/header.elv'
        eval (slurp < $header)

        unset-env KOOPA_ACTIVATE
    }
}
