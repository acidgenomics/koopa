#!/usr/bin/env zsh

# Configure prompt.
# Updated 2019-10-31.

# See also:
# - https://github.com/sindresorhus/pure
# - https://github.com/sindresorhus/pure/wiki

# This won't work if an oh-my-zsh theme is enabled.
# This step must be sourced after oh-my-zsh.

setopt promptsubst
autoload -U promptinit
promptinit
prompt koopa
