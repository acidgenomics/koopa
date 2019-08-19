#!/usr/bin/env zsh

# Configure prompt.
# Updated 2019-08-16.

# See also:
# - https://github.com/sindresorhus/pure
# - https://github.com/sindresorhus/pure/wiki

# This won't work if an oh-my-zsh theme is enabled.
# This step must be sourced after oh-my-zsh.

autoload -U promptinit
promptinit
prompt koopa
