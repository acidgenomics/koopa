#!/bin/sh

# GNU dircolors for ls.
# Updated 2019-10-29.

if _koopa_is_installed dircolors
then
    # Use the custom colors defined in dotfiles, if possible.
    if [ -f "${KOOPA_HOME}/dotfiles/dircolors" ]
    then
        eval "$(dircolors "${KOOPA_HOME}/dotfiles/dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi
