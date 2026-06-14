# Elvish header.
# @note Updated 2026-06-14.

use str

# Assemble all function-file bodies into a single string and eval it ONCE,
# so every function shares one namespace and can call each other.
# (Elvish `eval` uses an isolated namespace per call — per-file eval hides
# the defined functions from the caller and from each other.)
var fn-parts = []
for dir [core prefix export activate] {
    var fn-dir = $E:KOOPA_PREFIX'/lang/elvish/functions/'$dir
    for f [$fn-dir/*[nomatch-ok].elv] {
        # activate-koopa.elv is appended last (see below) — skip it here.
        if (not (str:has-suffix $f '/activate-koopa.elv')) {
            set fn-parts = (conj $fn-parts (slurp < $f))
        }
    }
}
# activate-koopa.elv must load LAST among activate/ files. Elvish fn definitions
# capture the namespace at execution time (closure semantics), so activate-starship
# and activate-zoxide — which sort after activate-koopa alphabetically — would be
# missing from the captured scope if activate-koopa.elv loaded in filename order.
set fn-parts = (conj $fn-parts (slurp < $E:KOOPA_PREFIX'/lang/elvish/functions/activate/activate-koopa.elv'))

# Hoist module imports to the TOP of the assembled blob. `use` is resolved
# lexically at compile time, and several function files reference path:/
# platform:/str:/math: without their own `use`. Hoisting makes them visible
# to all functions. Duplicate `use` lines in individual files are harmless.
var fn-header = (str:join "\n" ['use path' 'use platform' 'use str' 'use math'])

# The activation driver runs LAST — after all fn definitions are in scope.
var fn-driver = "
if (not (has-env KOOPA_DEFAULT_SYSTEM_PATH)) {
    set-env KOOPA_DEFAULT_SYSTEM_PATH (str:join ':' $paths)
}
if (and (has-env KOOPA_ACTIVATE) (eq $E:KOOPA_ACTIVATE '1')) { activate-koopa }
"

eval (str:join "\n" [$fn-header (str:join "\n" $fn-parts) $fn-driver])
