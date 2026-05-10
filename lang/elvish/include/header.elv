# Elvish header.
# @note Updated 2026-05-01.

use path
use platform
use str

# Source function files.
for dir [core prefix export activate] {
    var fn-dir = $E:KOOPA_PREFIX'/lang/elvish/functions/'$dir
    if (path:is-dir $fn-dir) {
        for f [(path:glob $fn-dir'/*.elv')] {
            eval (slurp < $f)
        }
    }
}

# Save default system PATH.
if (not (has-env KOOPA_DEFAULT_SYSTEM_PATH)) {
    set-env KOOPA_DEFAULT_SYSTEM_PATH (str:join ':' $paths)
}

# Activation.
fn activate-koopa {
    var koopa-minimal = '0'
    if (has-env KOOPA_MINIMAL) {
        set koopa-minimal = $E:KOOPA_MINIMAL
    }

    activate-bootstrap
    add-to-path-start $E:KOOPA_PREFIX'/bin'

    if (eq $koopa-minimal '1') {
        return
    }

    export-env
    activate-fzf
    activate-direnv
    activate-zoxide

    # macOS-specific: Homebrew.
    if (eq $platform:os 'darwin') {
        if (path:is-regular &follow-symlink '/opt/homebrew/bin/brew') {
            eval (e:/opt/homebrew/bin/brew shellenv)
        } elif (path:is-regular &follow-symlink '/usr/local/bin/brew') {
            eval (e:/usr/local/bin/brew shellenv)
        }
    }

    # Final PATH additions.
    add-to-path-start ^
        '/usr/local/sbin' ^
        '/usr/local/bin' ^
        (xdg-config-home)'/koopa/scripts-private/bin' ^
        $E:HOME'/.local/bin' ^
        $E:HOME'/.bin' ^
        $E:HOME'/bin'

    activate-aliases
    activate-starship
}

if (and (has-env KOOPA_ACTIVATE) (eq $E:KOOPA_ACTIVATE '1')) {
    activate-koopa
}
