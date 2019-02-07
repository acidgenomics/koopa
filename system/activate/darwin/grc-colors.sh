#!/bin/sh

# Enable more colors with grc.

# shellcheck disable=SC1090
[ -f "$HOMEBREW_PREFIX/etc/grc.bashrc" ] && \
    . "$HOMEBREW_PREFIX/etc/grc.bashrc"
