#!/bin/sh

# Homebrew

if quiet_which brew
then
    HOMEBREW_PREFIX="$(brew --prefix)"
    export HOMEBREW_PREFIX
    HOMEBREW_REPOSITORY="$(brew --repo)"
    export HOMEBREW_REPOSITORY
    export HOMEBREW_INSTALL_CLEANUP=1
    # Disable tracking with Google Analytics.
    export HOMEBREW_NO_ANALYTICS=1
fi
