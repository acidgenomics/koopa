#!/usr/bin/env zsh

# oh-my-zsh configuration
# Updated 2019-10-29.

# See also:
# - https://github.com/robbyrussell/oh-my-zsh/blob/master/templates/
#       zshrc.zsh-template
# - https://github.com/robbyrussell/oh-my-zsh
# - https://github.com/robbyrussell/oh-my-zsh/wiki
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins-Overview
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Customization
# - https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes

[[ -z "${KOOPA_TEST:-}" ]] || return 0

export ZSH="${HOME}/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH}/custom"

# Note that this can slow down ZSH but is useful for debugging.
# > export ZSH_COMPDUMP="/tmp/zcompdump-${USER}"

# Ignore warning about insecure directories identified by compfix.
# > compaudit | xargs chmod g-w
# > ZSH_DISABLE_COMPFIX="true"

if [[ ! -d "$ZSH" ]]
then
    install-oh-my-zsh "$ZSH"
fi

# ENABLE_CORRECTION="true"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="yyyy-mm-dd"
HYPHEN_INSENSITIVE="true"
ZSH_THEME=""

# Standard plugins can be found in '~/.oh-my-zsh/plugins/'.
# Custom plugins may be added to '~/.oh-my-zsh/custom/plugins/'.
# zsh-syntax-highlighting plugin is cool but slows down paste into terminal.

custom_plugins=(
    zsh-autosuggestions
    # zsh-syntax-highlighting
)

for plugin in "${custom_plugins[@]}"
do
    if [[ ! -d "${ZSH_CUSTOM}/plugins/${plugin}" ]]
    then
        "install-${plugin}"
    fi
done

plugins=(
    colored-man-pages
    command-not-found
    git
    rsync
    tmux
    vi-mode
    "${custom_plugins[@]}"
)

source "${ZSH}/oh-my-zsh.sh"

# Overrides                                                                 {{{1
# ==============================================================================

# Darken the autosuggest text color.
# Define using xterm-256 color code.
#
# See also:
# - https://stackoverflow.com/questions/47310537
# - https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
#
# This works well in combo with Dracula theme.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
