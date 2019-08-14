#!/usr/bin/env zsh

# Set options
# Updated 2019-08-14.

# Allow tab completion in the middle of a word.
setopt COMPLETE_IN_WORD

# Restart running processes on exit.
# > setopt HUP

# Don't hang up background jobs.
setopt NO_HUP

# Append history file.
setopt APPEND_HISTORY

# For sharing history between zsh processes.
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Don't show duplicate history entires.
setopt HIST_FIND_NO_DUPS

# Remove unnecessary blanks from history.
setopt HIST_REDUCE_BLANKS

# Keep background processes at full speed.
# > setopt NOBGNICE
