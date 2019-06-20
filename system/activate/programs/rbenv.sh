#!/bin/sh

# Ruby environment manager (rbenv).
# Modified 2019-06-19.

# See also:
# - https://github.com/rbenv/rbenv

# Alternate approaches:
# > add_to_path_start "$(rbenv root)/shims"
# > add_to_path_start "${HOME}/.rbenv/shims"

# Configure shared installation, if necessary.
if ! _koopa_quiet_which rbenv && [ -d "/usr/local/rbenv" ]
then
    export RBENV_ROOT="/usr/local/rbenv"
    _koopa_add_to_path_start "${RBENV_ROOT}/bin"
fi

if _koopa_quiet_which rbenv
then
    eval "$(rbenv init -)"
fi
