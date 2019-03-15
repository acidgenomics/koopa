#!/usr/bin/env bash

# Define the prompt string.

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
# CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
# export CONDA_PROMPT_MODIFIER
# conda="$CONDA_PROMPT_MODIFIER"

history="[c\#; h\!]"
prompt="\$"
# Unicode doesn't work with PuTTY on Windows.
# prompt="❯"
# Only show the user/host for SSH.
user="\u@\h"
# Alternatively, can use `\w`, which will show "~".
# https://askubuntu.com/questions/388913
# https://help.ubuntu.com/community/CustomizingBashPrompt
# wd="\w"
wd="\$PWD"

# Enable colorful prompt.
# Match either "xterm-256color" or "screen-256color" here.
if [[ "$TERM" =~ -256color ]]
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

    # Dynamically change the user color based on connection type.
    if [[ -n "$SSH_CONNECTION" ]]
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

PS1="\n${user} ${history}\n${wd}\n${prompt} "
export PS1

unset -v history prompt prompt_color user user_color wd wd_color
