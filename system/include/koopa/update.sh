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
# /usr/local/cellar
cellar_prefix="$(_koopa_cellar_prefix)"

_koopa_message "Updating koopa at '${koopa_prefix}'."

if _koopa_is_shared_install
then
    _koopa_note "Shared installation detected."
    _koopa_note "sudo privileges are required."
    _koopa_assert_has_sudo
fi

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

if [[ "$system" -eq 1 ]]
then
    echo "config prefix: ${config_prefix}"
    echo "app prefix: ${app_prefix}"
    echo "make prefix: ${make_prefix}"
fi

# Ensure accidental swap files created by vim get nuked.
find . -type f -name "*.swp" -delete

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
)

if [[ "$system" -eq 1 ]]
then
    _koopa_message "Updating system configuration."
    if _koopa_is_macos
    then
        update-homebrew
        update-r-packages
    fi
    if _koopa_is_installed configure-vm
    then
        configure-vm
    else
        update-conda
        update-venv
        update-rust
    fi
    # Update managed git repos.
    _koopa_update_git_repo "${HOME}/.emacs.d-doom"
    _koopa_update_git_repo "${HOME}/.emacs.d-spacemacs"
    _koopa_update_git_repo "${XDG_DATA_HOME}/Rcheck"
    if _koopa_is_linux && _koopa_is_shared_install
    then
        _koopa_remove_broken_symlinks "$make_prefix"
        _koopa_remove_broken_symlinks "$app_prefix"
        if _koopa_is_installed zsh
        then
            _koopa_message "Fixing Zsh permissions to pass compaudit checks."
            zsh_exe="$(_koopa_which_realpath zsh)"
            if _koopa_is_matching_regex "$zsh_exe" "^${make_prefix}"
            then
                sudo chmod -v g-w \
                    "/usr/local/share/zsh" \
                    "/usr/local/share/zsh/site-functions"
            fi
            if _koopa_is_matching_regex "$zsh_exe" "^${cellar_prefix}"
            then
                sudo chmod -v g-w \
                    "/usr/local/cellar/zsh/"*"/share/zsh" \
                    "/usr/local/cellar/zsh/"*"/share/zsh/"* \
                    "/usr/local/cellar/zsh/"*"/share/zsh/"*"/functions"
            fi
        fi
        # Ensure Python pyenv shims have correct permissions.
        pyenv_prefix="$(_koopa_pyenv_prefix)"
        if [[ -d "${pyenv_prefix}/shims" ]]
        then
            _koopa_message "Fixing pyenv shim permissions."
            sudo chmod -v 0777 "${pyenv_prefix}/shims"
        fi
    fi
fi

# Avoid compaudit warnings regarding group write access. Note that running
# 'compinit-compaudit-fix' script will cause the shell session to exit, so don't
# run here.
if _koopa_is_shared_install
then
    sudo chmod -v g-w \
        "${koopa_prefix}/shell/zsh" \
        "${koopa_prefix}/shell/zsh/functions"
fi

_koopa_success "koopa update was successful."
_koopa_note "Shell must be reloaded for changes to take effect."
