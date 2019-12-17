#!/usr/bin/env zsh

# Initialize ZSH plugins.
# Updated 2019-12-17.

ZSH_PLUGINS_DIR="${KOOPA_PREFIX}/dotfiles/shell/zsh/plugins"
[[ -d "$ZSH_PLUGINS_DIR" ]] || return 0

# This error is now popping up:
# _zsh_autosuggest_highlight_apply:3: POSTDISPLAY: parameter not set

# > if [[ -d "${ZSH_PLUGINS_DIR}/zsh-autosuggestions" ]]
# > then
# >     source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
# > fi

# Set the autosuggest text color.
# Define using xterm-256 color code.
#
# See also:
# - https://stackoverflow.com/questions/47310537
# - https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
#
# 'fg=240' also works well with Dracula theme.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=005"

unset -v ZSH_PLUGINS_DIR
