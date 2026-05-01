#!/usr/bin/env fish

# Fish header.
# @note Updated 2026-05-01.
# @note Requires fish 3.0+.

# Version guard.
set -l fish_major (string split '.' "$FISH_VERSION")[1]
if test "$fish_major" -lt 3
    return 0
end

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
    if test "$koopa_minimal" -eq 1
        return 0
    end
    _koopa_export_env
    _koopa_activate_fzf
    _koopa_activate_direnv
    _koopa_activate_zoxide
    _koopa_activate_conda
    _koopa_activate_broot
    _koopa_activate_mcfly
    if _koopa_is_macos
        # macOS-specific: Homebrew.
        if test -x /opt/homebrew/bin/brew
            eval (/opt/homebrew/bin/brew shellenv fish)
        else if test -x /usr/local/bin/brew
            eval (/usr/local/bin/brew shellenv fish)
        end
    end
    _koopa_add_to_path_start \
        /usr/local/sbin \
        /usr/local/bin \
        (_koopa_scripts_private_prefix)/bin \
        (_koopa_xdg_local_home)/bin \
        "$HOME/.bin" \
        "$HOME/bin"
    if not _koopa_is_subshell
        # Create today bucket symlink.
        set -l today_dir "$HOME/today"
        if not test -e "$today_dir"
            set -l date_str (date '+%Y/%m/%d')
            set -l bucket_dir "$HOME/$date_str"
            if not test -d "$bucket_dir"
                mkdir -p "$bucket_dir"
            end
            ln -fns "$bucket_dir" "$today_dir"
        end
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
