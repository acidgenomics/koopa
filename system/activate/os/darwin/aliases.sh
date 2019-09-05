#!/bin/sh

# Aliases
# Updated 2019-09-05.

alias autofs="sudo automount -vc"
alias finder-hide="setfile -a V"
alias icloud-status="brctl log --wait --shorten"
alias locate="mdfind -name"
alias rstudio="open -a rstudio"

# Use `exa` instead of `ls`, if installed.
# It has better color support.
# See also: https://the.exa.website/
if _koopa_quiet_which exa
then
    alias ls="exa -Fg"
fi
