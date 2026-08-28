#!/usr/bin/env fish

# Fish header.
# @note Updated 2026-05-01.
# @note Requires fish 3.0+.

# Version guard.
set -l fish_major (string split '.' "$FISH_VERSION")[1]
if test "$fish_major" -lt 3
    return 0
end

# Cache OS name once to avoid repeated uname forks.
set -g __koopa_os (uname -s)

# Source function files.
for __kvar_file in $KOOPA_PREFIX/lang/fish/functions/*/*.fish
    source "$__kvar_file"
end
set -e __kvar_file

# Save default system PATH.
if not set -q KOOPA_DEFAULT_SYSTEM_PATH
    set -gx KOOPA_DEFAULT_SYSTEM_PATH $PATH
end

# --------------------------------------------------------------------------- #
# Activation.
# --------------------------------------------------------------------------- #

function __koopa_activate_koopa
    # Activate koopa.
    # @note Updated 2026-05-01.
    set -l koopa_minimal 0
    if set -q KOOPA_MINIMAL
        set koopa_minimal "$KOOPA_MINIMAL"
    end
    _koopa_activate_bootstrap
    _koopa_add_to_path_start "$KOOPA_PREFIX/bin"
    _koopa_add_to_manpath_start "$KOOPA_PREFIX/share/man"
    if test "$koopa_minimal" -eq 1
        return 0
    end
    _koopa_export_env
    _koopa_activate_ca_certificates
    _koopa_activate_ruby
    _koopa_activate_julia
    _koopa_activate_python
    _koopa_activate_pipx
    _koopa_activate_bat
    _koopa_activate_difftastic
    _koopa_activate_dircolors
    _koopa_activate_docker
    _koopa_activate_fzf
    _koopa_activate_lesspipe
    _koopa_activate_pyright
    _koopa_activate_ripgrep
    _koopa_activate_tealdeer
    if _koopa_is_macos
        # macOS-specific: Homebrew.
        if test -x /opt/homebrew/bin/brew
            eval (/opt/homebrew/bin/brew shellenv fish)
        else if test -x /usr/local/bin/brew
            eval (/usr/local/bin/brew shellenv fish)
        end
    end
    _koopa_activate_micromamba
    _koopa_add_to_path_start \
        /usr/local/sbin \
        /usr/local/bin \
        "$XDG_CONFIG_HOME/koopa/scripts-private/bin" \
        "$XDG_CONFIG_HOME/koopa/dotfiles/bin" \
        "$XDG_CONFIG_HOME/koopa/dotfiles-work/bin" \
        "$XDG_CONFIG_HOME/koopa/dotfiles-personal/bin" \
        "$XDG_CONFIG_HOME/koopa/dotfiles-private/bin" \
        "$HOME/.local/bin" \
        "$HOME/.bin" \
        "$HOME/bin"
    _koopa_add_to_manpath_start \
        /usr/local/man \
        /usr/local/share/man
    _koopa_add_to_manpath_end /usr/share/man
    _koopa_activate_zoxide
    _koopa_activate_conda
    _koopa_activate_broot
    _koopa_activate_atuin
    _koopa_activate_pyenv
    _koopa_activate_rbenv
    _koopa_activate_direnv
    if not _koopa_is_subshell
        _koopa_activate_today_bucket
    end
    _koopa_activate_aliases
end

set -l koopa_activate 0
if set -q KOOPA_ACTIVATE
    set koopa_activate "$KOOPA_ACTIVATE"
end

if test "$koopa_activate" -eq 1
    __koopa_activate_koopa
    set -l koopa_minimal 0
    if set -q KOOPA_MINIMAL
        set koopa_minimal "$KOOPA_MINIMAL"
    end
    if test "$koopa_minimal" -eq 0
        _koopa_activate_starship
        _koopa_activate_fish_extras
    end
end

functions -e __koopa_activate_koopa
