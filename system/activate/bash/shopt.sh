#!/usr/bin/env bash

# Set up text editor.
# Using vi mode instead of emacs by default.
set -o vi

# Correct minor directory changing spelling mistakes.
shopt -s cdspell

# Check the window size after each command.
# If necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable history appending instead of overwriting.
shopt -s histappend

# Save multiline commands.
shopt -s cmdhist
