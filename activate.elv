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
        # Note: elvish cannot self-locate a script sourced via `eval (slurp < ...)` —
        # `(src)[name]` returns `[eval N]` in that context, so `path:dir` would yield
        # `.` (relative). rc.elv already sets KOOPA_PREFIX correctly (absolute, from
        # XDG) before calling this file, so we trust it. Mirror bash activate.sh:98,
        # which keeps KOOPA_PREFIX when already set and valid.
        if (not (and (has-env KOOPA_PREFIX) (path:is-dir $E:KOOPA_PREFIX))) {
            return
        }

        set-env KOOPA_ACTIVATE '1'

        var header = $E:KOOPA_PREFIX'/lang/elvish/include/header.elv'
        eval (slurp < $header)

        unset-env KOOPA_ACTIVATE
    }
}
