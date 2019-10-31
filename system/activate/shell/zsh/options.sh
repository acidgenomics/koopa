#!/usr/bin/env zsh

# ZSH shell options.
# Updated 2019-10-31.

# See also:
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html
# - http://zsh.sourceforge.net/Doc/Release/Options.html

# Vim key bindings.
# Use '-e' for Emacs.
bindkey -v

# Disable auto-correction.
unsetopt correct
unsetopt correct_all
DISABLE_CORRECTION="true"

# Disable trailing slash '/' on tab auto-completion of directory names.
# FIXME This isn't working for zsh.
# setopt noautoparamkeys
# setopt noautoparamslash

# setopt no_auto_remove_slash
# setopt auto_remove_slash

# unsetopt NO_AUTO_REMOVE_SLASH
# setopt AUTO_REMOVE_SLASH

zstyle ':completion:*' path-completion false
zstyle ':completion:*' accept-exact-dirs true




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
