#!/usr/bin/env bash

# Bash shell options.
# Updated 2019-10-31.

# Disable trailing slash '/' on tab auto-completion of directory names.
# Using INPUTRC approach instead (see '~/.inputrc').
# > bind 'set mark-directories off'

# Correct minor directory changing spelling mistakes.
shopt -s cdspell

# Check the window size after each command.
# If necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Save multiline commands.
shopt -s cmdhist

# Enable history appending instead of overwriting.
shopt -s histappend
