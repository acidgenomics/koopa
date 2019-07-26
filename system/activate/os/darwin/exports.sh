#!/bin/sh

## Improve terminal colors.
export CLICOLOR=1
export GREP_OPTIONS="--color=auto"
## Refer to `man ls` for `LSCOLORS` section on color designators.
## export LSCOLORS="Gxfxcxdxbxegedabagacad"

## Set rsync flags for APFS.
export RSYNC_FLAGS_APFS="${RSYNC_FLAGS} --iconv=utf-8,utf-8-mac"
