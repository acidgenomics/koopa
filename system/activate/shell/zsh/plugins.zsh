#!/usr/bin/env zsh

# """
# Initialize ZSH plugins.
# Updated 2019-12-17.
#
# Debug plugins via:
# > zsh -df
# > source "${ZSH_PLUGINS_DIR}/XXX/XXX.zsh"
# """

ZSH_PLUGINS_DIR="${KOOPA_PREFIX}/dotfiles/shell/zsh/plugins"
[[ -d "$ZSH_PLUGINS_DIR" ]] || return 0
export ZSH_PLUGINS_DIR

if [[ -d "${ZSH_PLUGINS_DIR}/zsh-autosuggestions" ]]
then
    source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Set the autosuggest text color.
# Define using xterm-256 color code.
#
# 'fg=240' also works well with Dracula theme.
#
# See also:
# - https://stackoverflow.com/questions/47310537
# - https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
#
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=005"
