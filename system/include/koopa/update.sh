#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Update koopa installation.
# Updated 2019-09-09.

config_dir="$(_koopa_config_dir)"

# spacemacs
if [[ -x "${config_dir}/rbenv" ]]
then
    printf "Updating rbenv.\n"
    (
        cd "${config_dir}/rbenv" || exit 1
        git pull
    )
fi

# spacemacs
if [[ -x "${config_dir}/spacemacs" ]]
then
    printf "Updating spacemacs.\n"
    (
        cd "${config_dir}/spacemacs" || exit 1
        git pull
    )
fi

# oh-my-zsh
if [[ -x "${config_dir}/oh-my-zsh" ]]
then
    printf "Updating Oh My Zsh.\n"
    (
        cd "${config_dir}/oh-my-zsh" || exit 1
        git pull
    )
fi

# Update repo.
printf "Updating koopa.\n"
(
    cd "$KOOPA_HOME" || exit 1
    git fetch --all
    git checkout master
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
