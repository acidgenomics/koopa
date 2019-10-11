#!/bin/sh

# Homebrew
# Updated 2019-10-11.

if _koopa_is_installed brew
then
    HOMEBREW_PREFIX="$(brew --prefix)"
    export HOMEBREW_PREFIX
    HOMEBREW_REPOSITORY="$(brew --repo)"
    export HOMEBREW_REPOSITORY
    export HOMEBREW_INSTALL_CLEANUP=1
    # Disable tracking with Google Analytics.
    export HOMEBREW_NO_ANALYTICS=1
fi

# Python
#
# See also:
# - https://docs.brew.sh/Homebrew-and-Python
# - brew info python
#
# Don't add to PATH if a virtual environment is active.
if [ -z "${VIRTUAL_ENV:-}" ]
then
    _koopa_add_to_path_start /usr/local/opt/python/libexec/bin
fi
