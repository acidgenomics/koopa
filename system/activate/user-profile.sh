#!/bin/sh

# Source user configuration profile files.
# Updated 2019-08-14.

if _koopa_is_login
then
    case "$KOOPA_SHELL" in
        bash)
            file="${HOME}/.bash_profile"
            ;;
        zsh)
            file="${HOME}/.zprofile"
    esac
    if [ -f "$file" ]
    then
        # shellcheck source=/dev/null
        . "$file"
    fi
    unset -v file
fi

if _koopa_is_interactive
then
    case "$KOOPA_SHELL" in
        bash)
            file="${HOME}/.bashrc"
            ;;
        zsh)
            file="${HOME}/.zshrc"
            ;;
    esac
    if [ -f "$file" ]
    then
        # shellcheck source=/dev/null
        . "$file"
    fi
    unset -v file
fi
