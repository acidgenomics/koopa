# Activate Homebrew for Elvish.
# @note Updated 2026-06-14.
# @note `brew shellenv` only supports bash/zsh/fish/csh/pwsh and emits bash
#   `export` syntax, so we set the environment directly — mirroring
#   lang/bash/functions/macos/macos-activate-homebrew.sh.

fn activate-homebrew {
    use path
    var prefix = '/opt/homebrew'
    if (not (path:is-regular &follow-symlink $prefix'/bin/brew')) {
        set prefix = '/usr/local'
    }
    if (not (path:is-regular &follow-symlink $prefix'/bin/brew')) {
        return
    }
    set-env HOMEBREW_PREFIX $prefix
    add-to-path-start $prefix'/bin'
    var brewfile = (xdg-config-home)'/homebrew/Brewfile'
    if (and (not (has-env HOMEBREW_BUNDLE_FILE_GLOBAL)) ^
            (path:is-regular &follow-symlink $brewfile)) {
        set-env HOMEBREW_BUNDLE_FILE_GLOBAL $brewfile
    }
    if (not (has-env HOMEBREW_CLEANUP_MAX_AGE_DAYS)) { set-env HOMEBREW_CLEANUP_MAX_AGE_DAYS '30' }
    if (not (has-env HOMEBREW_INSTALL_CLEANUP)) { set-env HOMEBREW_INSTALL_CLEANUP '1' }
    if (not (has-env HOMEBREW_NO_ENV_HINTS)) { set-env HOMEBREW_NO_ENV_HINTS '1' }
}
