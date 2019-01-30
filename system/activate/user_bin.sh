#!/bin/ssh

# Export local user binaries, if directories exist.

# Bash alternate for PATH expansion:
# [[ ":$PATH:" != *":${dir}:"* ]]

dir="${HOME}/.local/bin"
if [ -d "$dir" ]
then
    case "$PATH" in
        "$dir") ;;
             *) add_to_path_start "$dir";;
    esac
fi

dir="${HOME}/bin"
if [ -d "$dir" ]
then
    case "$PATH" in
        "$dir") ;;
             *) add_to_path_start "$dir";;
    esac
fi

unset -v dir
