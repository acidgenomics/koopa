#!/usr/bin/env zsh

# Initialize ZSH plugins.
# Updated 2019-11-10.

_koopa_activate_autojump

plugins_dir="${KOOPA_HOME}/dotfiles/shell/zsh/plugins"
[[ -d "$plugins_dir" ]] || return 0

if [[ -d "${plugins_dir}/zsh-autosuggestions" ]]
then
    source "${plugins_dir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

unset -v plugins_dir

# Set the autosuggest text color.
# Define using xterm-256 color code.
#
# See also:
# - https://stackoverflow.com/questions/47310537
# - https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
#
# 'fg=240' also works well with Dracula theme.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=005"
