#!/usr/bin/env zsh

# Antigen.
# Updated 2019-11-01.
#
# See also:
# - https://github.com/zsh-users/antigen
# - https://github.com/zsh-users/antigen/wiki/Configuration

ADOTDIR="${HOME}/.antigen"
source "${KOOPA_PREFIX}/shell/zsh/include/antigen.zsh"

# Bundles from the default repo (robbyrussell's oh-my-zsh).
# > antigen use oh-my-zsh
# > antigen bundle command-not-found
# > antigen bundle git
# > antigen bundle heroku
# > antigen bundle lein
# > antigen bundle pip

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply
