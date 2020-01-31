#!/usr/bin/env bash
set -Eeu -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

# /usr/local/koopa
koopa_prefix="$(_koopa_prefix)"
# ~/.config/koopa
config_prefix="$(_koopa_config_prefix)"
# /n/app
app_prefix="$(_koopa_app_prefix)"
# /usr/local
make_prefix="$(_koopa_make_prefix)"

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

_koopa_h1 "Updating koopa at '${koopa_prefix}'."

if _koopa_is_shared_install
then
    if [[ "$system" -eq 1 ]]
    then
        _koopa_info "config prefix: ${config_prefix}"
        _koopa_info "make prefix: ${make_prefix}"
        _koopa_info "app prefix: ${app_prefix}"
        echo
    fi
    _koopa_note "Shared installation detected."
    _koopa_note "sudo privileges are required."
    _koopa_assert_has_sudo
fi

# Ensure accidental swap files created by vim get nuked.
find "$koopa_prefix" -type f -name "*.swp" -delete

# Ensure invisible files get nuked on macOS.
if _koopa_is_macos
then
    find "$koopa_prefix" -type f -name ".DS_Store" -delete
fi

_koopa_set_permissions "$koopa_prefix"
_koopa_update_xdg_config
_koopa_update_ldconfig
_koopa_update_profile

# Loop across config directories and update git repos.
# Consider nesting these under 'app' directory.
_koopa_h1 "Updating user config at '${config_prefix}'."
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
)

if [[ "$system" -eq 1 ]]
then
    _koopa_h1 "Updating system configuration."
    update-conda
    if _koopa_is_macos
    then
        update-homebrew
        update-r-packages
    elif _koopa_is_installed configure-vm
    then
        configure-vm
    fi
    # Update managed git repos.
    _koopa_update_git_repo "${HOME}/.emacs.d-doom"
    _koopa_update_git_repo "${HOME}/.emacs.d-spacemacs"
    _koopa_update_git_repo "${XDG_DATA_HOME}/Rcheck"
fi

_koopa_fix_zsh_permissions

_koopa_success "koopa update was successful."
_koopa_note "Shell must be reloaded for changes to take effect."
