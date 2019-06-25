#!/usr/bin/env bash

# Define the prompt string.
# Modified 2019-06-25.

# \#: the command number of this command
# \!: the history number of this command
# \H: hostname
# \W: working directory basename
# \h: hostname up to the first `.`
# \n: newline
# \r: carriage return
# \s: shell name, the basename of `$0`
# \u: username
# \w: working directory

# Add the conda environment name.
# Note that we have to source conda first (see shrc.rc above).
# https://stackoverflow.com/questions/42481726
# > CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
# > export CONDA_PROMPT_MODIFIER
# > conda="$CONDA_PROMPT_MODIFIER"

# User name and host.
user="\u@\h"

# Remote machine information.
mach=
if _koopa_is_remote
then
    host_type="$(_koopa_host_type)"
    [[ -n "$host_type" ]] && mach="${host_type}"
    os_type="$(_koopa_os_type)"
    [[ -n "$os_type" ]] && [[ -n "$mach" ]] && mach="${mach} ${os_type}"
    [[ -n "$mach" ]] && mach="[${mach}]"
fi

# Shell name.
shell="[$(_koopa_shell)]"

# History.
history="[c\#; h\!]"

# Working directory.
wd="\w"

# Unicode doesn't work with some monospace fonts on Windows.
# > prompt="\$"
prompt="❯"

# Enable colorful prompt.
# Match either "xterm-256color" or "screen-256color" here.
if [[ "${TERM:-}" =~ -256color ]]
then
    # Foreground colors (text)
    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    # 39 default
    # 30 black
    # 31 red
    # 32 green
    # 33 yellow
    # 34 blue
    # 35 magenta
    # 36 cyan
    # 37 light gray
    # 90 dark gray
    # 91 light red
    # 92 light green
    # 93 light yellow
    # 94 light blue
    # 95 light magenta
    # 96 light cyan
    # 97 white

    # Change the user color based on connection type.
    if _koopa_is_remote
    then
        user_color="33"
    else
        user_color="36"
    fi

    user="\[\033[01;${user_color}m\]${user}\[\033[00m\]"

    wd_color="34"
    wd="\[\033[01;${wd_color}m\]${wd}\[\033[00m\]"

    # Match the color of zsh pure prompt.
    prompt_color="35" 
    prompt="\[\033[01;${prompt_color}m\]${prompt}\[\033[00m\]"
fi

PS1="\n${user}"
[[ -n "$mach" ]] && PS1="${PS1} ${mach}"
PS1="${PS1} ${shell} ${history}\n"
PS1="${PS1}${wd}\n"
PS1="${PS1}${prompt} "
export PS1

unset -v history mach prompt prompt_color user user_color wd wd_color
