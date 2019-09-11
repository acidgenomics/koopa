#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# Update koopa installation.
# Updated 2019-09-11.

config_dir="$(_koopa_config_dir)"

# Loop across config directories and update git repos.
dirs=(
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
        git pull
    )
done

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
