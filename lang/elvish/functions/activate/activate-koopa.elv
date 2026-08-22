# Activate koopa for Elvish.
# @note Updated 2026-06-14.

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
    activate-ca-certificates
    activate-conda
    activate-fzf
    activate-direnv
    activate-zoxide

    # macOS-specific: Homebrew.
    if (eq $platform:os 'darwin') {
        activate-homebrew
    }

    # Final PATH additions.
    add-to-path-start ^
        '/usr/local/sbin' ^
        '/usr/local/bin' ^
        (xdg-config-home)'/koopa/scripts-private/bin' ^
        (xdg-config-home)'/koopa/dotfiles/bin' ^
        (xdg-config-home)'/koopa/dotfiles-work/bin' ^
        (xdg-config-home)'/koopa/dotfiles-personal/bin' ^
        (xdg-config-home)'/koopa/dotfiles-private/bin' ^
        $E:HOME'/.local/bin' ^
        $E:HOME'/.bin' ^
        $E:HOME'/bin'

    activate-difftastic
    activate-aliases
    activate-starship
    activate-color-mode-sync
}
