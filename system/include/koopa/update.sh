#!/usr/bin/env bash
set -Eeu -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

koopa_prefix="$(_koopa_prefix)"
_koopa_message "Updating koopa at '${koopa_prefix}'."

system=0

while (("$#"))
do
    case "$1" in
        --system)
            system=1
            shift 1
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
done

# Ensure invisible files get nuked on macOS.
if _koopa_is_darwin
then
    find "$koopa_prefix" -name ".DS_Store" -delete
fi

# _koopa_remove_broken_symlinks "$(_koopa_config_prefix)"

# Loop across config directories and update git repos.
# Consider nesting these under 'app' directory.
config_prefix="$(_koopa_config_prefix)"
_koopa_message "Updating user config at '${config_prefix}'."

rm -frv "${config_prefix}/"{Rcheck,autojump,oh-my-zsh,pyenv,rbenv,spacemacs}

repos=(
    docker
    dotfiles
    dotfiles-private
    scripts-private
)
for repo in "${repos[@]}"
do
    repo="${config_prefix}/${repo}"
    _koopa_update_git_repo "$repo"
done

(
    cd "$koopa_prefix" || exit 1
    git fetch --all
    # > git checkout master
    git pull
    _koopa_set_permissions "$koopa_prefix"
)

_koopa_update_xdg_config
_koopa_update_ldconfig
_koopa_update_profile

if [[ "$system" -eq 1 ]]
then
    _koopa_message "Updating system configuration."
    if _koopa_is_darwin
    then
        update-homebrew
        update-r-packages
        # > if _koopa_has_sudo
        # > then
        # >     update-tex
        # > fi
    fi
    if _koopa_is_azure
    then
        # We're rsyncing config, so don't update conda.
        update-azure-vm --all
    else
        update-conda
    fi
    update-venv
    update-rust
    _koopa_update_git_repo "${HOME}/.emacs.d-doom"
    _koopa_update_git_repo "${HOME}/.emacs.d-spacemacs"
    _koopa_update_git_repo "${XDG_DATA_HOME}/Rcheck"
    _koopa_update_git_repo "${XDG_DATA_HOME}/pyenv"
    _koopa_update_git_repo "${XDG_DATA_HOME}/rbenv"
    if _koopa_is_linux
    then
        _koopa_reset_prefix_permissions
        prefix="$(_koopa_make_prefix)"
        remove-broken-symlinks "$prefix"
        remove-empty-dirs "$prefix"
        remove-broken-cellar-symlinks
    fi
fi

_koopa_success "koopa update was successful."
_koopa_note "Shell must be reloaded for changes to take effect."
