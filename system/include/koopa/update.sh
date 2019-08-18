#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(_koopa_header bash)"

# Update koopa installation.
# Updated 2019-08-14.

# Update repo.
(
    cd "$KOOPA_HOME" || exit 1
    git fetch --all
    git checkout master
    git pull
)

# Clean up legacy files.
if [[ -d "${KOOPA_HOME}/dotfiles" ]]
then
    rm -frv "${KOOPA_HOME}/dotfiles"
fi
if [[ -d "${KOOPA_HOME}/system/config" ]]
then
    rm -frv "${KOOPA_HOME}/system/config"
fi

cat << EOF
koopa updated successfully.
Shell must be reloaded for changes to take effect.
EOF
