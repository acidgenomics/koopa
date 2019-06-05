#!/bin/sh

# Check that platform is supported.

# Bash sets the shell variable OSTYPE (e.g. linux-gnu).
# However, this doesn't work consistently with zsh, so use uname instead.

osname="$(uname -s)"
case "$osname" in
    Darwin) export MACOS=1 && export UNIX=1;;
     Linux) export LINUX=1 && export UNIX=1;;
         *) echo "Unsupported operating system."; exit 1;;
esac
unset -v osname

