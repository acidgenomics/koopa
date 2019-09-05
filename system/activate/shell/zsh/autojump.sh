#!/usr/bin/env zsh

# Configure autojump.
# Updated 2019-09-05.

# See also:
# - https://github.com/wting/autojump

base_dir="${HOME}/.autojump"
script="${base_dir}/etc/profile.d/autojump.sh"

if [[ -s "$script"  ]]
then
    source "$script"
    autoload -U compinit && compinit -u
fi

unset -v base_dir script
