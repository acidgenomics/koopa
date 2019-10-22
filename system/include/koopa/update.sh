#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"

# Update koopa installation.
# Updated 2019-10-22.



# Programs                                                                  {{{1
# ==============================================================================

update-conda
update-venv
update-rust
update-r-packages

# OS-specific                                                               {{{2
# ------------------------------------------------------------------------------

if _koopa_is_darwin
then
    update-homebrew
elif _koopa_is_linux
then
    reset-prefix-permissions
    remove-broken-cellar-symlinks
    # FIXME Remove empty directories in prefix and cellar
fi

# Sudo permissions                                                          {{{2
# ------------------------------------------------------------------------------

# > if _koopa_has_sudo
# > then
# >     update-tex
# > fi



# Config dirs                                                               {{{1
# ==============================================================================

config_dir="$(_koopa_config_dir)"

# Loop across config directories and update git repos.
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
    printf "Updating %s.\n" "$dir"
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
printf "Updating koopa.\n"
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

cat << EOF

koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF
