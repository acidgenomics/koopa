#!/bin/sh

# Homebrew
# Updated 2019-06-20.

if _koopa_quiet_which brew
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
# https://docs.brew.sh/Homebrew-and-Python
# > brew info python
# > python -V
_koopa_add_to_path_start /usr/local/opt/python/libexec/bin
