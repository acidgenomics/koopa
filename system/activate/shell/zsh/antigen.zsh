#!/usr/bin/env zsh

# Antigen.
# Updated 2019-10-31.
#
# See also:
# - https://github.com/zsh-users/antigen
# - https://github.com/zsh-users/antigen/wiki/Configuration

ADOTDIR="${HOME}/.antigen"

source "${KOOPA_HOME}/shell/zsh/include/antigen.zsh"

# antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
# antigen bundle git
# antigen bundle heroku
# antigen bundle pip
# antigen bundle lein
# antigen bundle command-not-found

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply
