#!/bin/sh

# Aliases

alias autofs="sudo automount -vc"
alias finder-hide="setfile -a V"
alias icloud-status="brctl log --wait --shorten"
alias locate="mdfind -name"
alias rstudio="open -a rstudio"

# Use exa instead of ls, if installed.
# It has better color support.
# https://the.exa.website/
if quiet_which exa
then
    alias ls="exa -Fg"
else
    alias ls="ls -F"
fi
