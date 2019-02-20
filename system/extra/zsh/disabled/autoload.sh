#!/bin/sh

# Info on `autoload -U`
# https://unix.stackexchange.com/questions/214296

# Enable completions.
#
# zsh compinit: insecure directories and files, run compaudit for list.
# This can freak out when using Homebrew zsh on a non-admin account.
#
# See also:
# - https://github.com/zsh-users/zsh-completions/issues/433
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html
# - https://github.com/zsh-users/zsh/blob/master/Completion/compinit
#
# Using the `-u` flag to ignore compaudit.
# autoload -U compinit; compinit
# autoload -U compinit -u; compinit -u

# Colorful prompt with Git branch information.
# autoload -U colors; colors

# Enable regex moving.
# autoload -U zmv
