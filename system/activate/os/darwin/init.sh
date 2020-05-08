#!/bin/sh

alias finder-hide="setfile -a V"
alias icloud-status="brctl log --wait --shorten"
alias locate="mdfind -name"
alias reload-mounts="sudo automount -vc"
alias rstudio="open -a rstudio"

# Improve terminal colors.
if [ -z "${CLICOLOR:-}" ]
then
    export CLICOLOR=1
fi

# Refer to 'man ls' for 'LSCOLORS' section on color designators.
# Note that this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
if [ -z "${LSCOLORS:-}" ]
then
    export LSCOLORS="Gxfxcxdxbxegedabagacad"
fi

# Set rsync flags for APFS.
if [ -z "${RSYNC_FLAGS_APFS:-}" ]
then
    export RSYNC_FLAGS_APFS="${RSYNC_FLAGS} --iconv=utf-8,utf-8-mac"
fi
