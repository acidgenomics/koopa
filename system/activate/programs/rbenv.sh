#!/bin/sh

# Ruby environment (rbenv).
# Modified 2019-06-18.

# See also:
# - https://github.com/rbenv/rbenv
# - https://github.com/rbenv/rbenv#how-rbenv-hooks-into-your-shell
# - https://blakewilliams.me/posts/system-wide-rbenv-install
# - https://devhints.io/rbenv

# Alternate approaches:
# > add_to_path_start "$(rbenv root)/shims"
# > add_to_path_start "${HOME}/.rbenv/shims"

# Configure shared installation, if necessary.
if ! quiet_which rbenv && [ -d "/usr/local/rbenv" ]
then
    export RBENV_ROOT="/usr/local/rbenv"
    add_to_path_start "${RBENV_ROOT}/bin"
fi

if quiet_which rbenv
then
    eval "$(rbenv init -)"
fi
