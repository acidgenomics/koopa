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

# _koopa_remove_broken_symlinks "$(_koopa_config_prefix)"

# Loop across config directories and update git repos.
# Consider nesting these under 'app' directory.
config_prefix="$(_koopa_config_prefix)"
_koopa_message "Updating user config at '${config_prefix}'."

# Rcheck
# autojump
# doom emacs
# oh-my-zsh
# rbenv
# pyenv
# spacemacs

repos=(
    docker
    dotfiles
    dotfiles-private
    scripts-private
)
for repo in "${repos[@]}"
do
    # Skip directories that aren't a git repo.
    if [[ ! -x "${config_prefix}/${repo}/.git" ]]
    then
        continue
    fi
    _koopa_message "Updating '${repo}'."
    (
        cd "${config_prefix}/${repo}" || exit 1
        # Run updater script, if defined.
        # Otherwise pull the git repo.
        if [[ -x "UPDATE.sh" ]]
        then
            ./UPDATE.sh
        else
            git fetch --all
            git pull
        fi
    )
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
    if _koopa_is_linux
    then
        reset-prefix-permissions
        prefix="$(_koopa_make_prefix)"
        remove-broken-symlinks "$prefix"
        remove-empty-dirs "$prefix"
        remove-broken-cellar-symlinks
    fi
fi

_koopa_success "koopa update was successful."
_koopa_note "Shell must be reloaded for changes to take effect."
