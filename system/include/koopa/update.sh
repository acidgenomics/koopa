#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

if _acid_is_darwin
then
    update-homebrew
    update-r-packages
    # > if _acid_has_sudo
    # > then
    # >     update-tex
    # > fi
fi

if _acid_is_azure
then
    update-azure-vm --all
else
    update-conda
fi

update-venv
update-rust

# Loop across config directories and update git repos.
config_dir="$(_acid_config_dir)"
dirs=(
    Rcheck
    docker
    dotfiles
    dotfiles-private
    oh-my-zsh
    rbenv
    scripts-private
    spacemacs
)
for dir in "${dirs[@]}"
do
    # Skip directories that aren't a git repo.
    if [[ ! -x "${config_dir}/${dir}/.git" ]]
    then
        continue
    fi
    _acid_message "Updating '${dir}'."
    (
        cd "${config_dir}/${dir}" || exit 1
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

# Update repo.
_acid_message "Updating koopa."
(
    cd "$KOOPA_HOME" || exit 1
    git fetch --all
    # > git checkout master
    git pull
)

# Clean up legacy files.
if [[ -d "${KOOPA_HOME}/system/config" ]]
then
    rm -frv "${KOOPA_HOME}/system/config"
fi

if _acid_is_linux
then
    reset-prefix-permissions
    prefix="$(_acid_build_prefix)"
    remove-broken-symlinks "$prefix"
    remove-empty-dirs "$prefix"
    remove-broken-cellar-symlinks
fi

# > remove-broken-symlinks "$HOME"

_acid_message "koopa update was successful."
_acid_note "Shell must be reloaded for changes to take effect."
