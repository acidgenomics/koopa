#!/usr/bin/env zsh

# oh-my-zsh configuration
# Updated 2019-08-26.

# See also:
# - https://github.com/robbyrussell/oh-my-zsh



# Install                                                                   {{{1
# ==============================================================================

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH}/custom"

# Install oh-my-zsh automatically, if necessary.
if [[ ! -d "$ZSH" ]]
then
    install-oh-my-zsh "$ZSH"
fi



# Updates                                                                   {{{1
# ==============================================================================

# > DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT=true
# > export UPDATE_ZSH_DAYS=14



# Security                                                                  {{{1
# ==============================================================================

# Ignore warning about insecure directories identified by compfix.
# > compaudit | xargs chmod g-w,o-w

ZSH_DISABLE_COMPFIX="true"



# Theme                                                                     {{{1
# ==============================================================================

# Set name of the theme to load.
# Set theme to empty string when using koopa prompt.

# See also:
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# - https://github.com/robbyrussell/oh-my-zsh/wiki/Customization#overriding-and-adding-themes
# - https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes

ZSH_THEME=""



# Completion                                                                {{{1
# ==============================================================================

# Enable case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to display red dots whilst waiting for
# completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# > HYPHEN_INSENSITIVE="true"



# Terminal window                                                           {{{1
# ==============================================================================

# Uncomment the following line to disable colors in ls.
# > DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"




# Git                                                                       {{{1
# ==============================================================================

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
#
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
#
# Or set a custom format using the strftime function format specifications.
# See 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"



# Plugins                                                                   {{{1
# ==============================================================================

# Standard plugins can be found in `~/.oh-my-zsh/plugins/`.
# Custom plugins may be added to `~/.oh-my-zsh/custom/plugins/`.

plugins_dir="${ZSH_CUSTOM}/plugins"

plugin="zsh-autosuggestions"
if [[ ! -d "${plugins_dir}/${plugin}" ]]
then
    "install-${plugin}"
fi

# > plugin="zsh-syntax-highlighting"
# > if [[ ! -d "${plugins_dir}/${plugin}" ]]
# > then
# >     "install-${plugin}"
# > fi

# zsh-syntax-highlighting
plugins=(
    git
    zsh-autosuggestions
)

unset -v plugins_dir


# Load Oh My Zsh                                                            {{{1
# ==============================================================================

if [ -z "${KOOPA_TEST:-}" ]
then
    source "${ZSH}/oh-my-zsh.sh"
fi



# Overrides                                                                 {{{1
# ==============================================================================

# Set personal aliases, overriding those provided by oh-my-zsh libs, plugins,
# and themes. Aliases can be placed here, though oh-my-zsh users are encouraged
# to define aliases within the ZSH_CUSTOM folder. For a full list of active
# aliases, run `alias`.
#
# Example aliases:
# > alias zshconfig="mate ~/.zshrc"
# > alias ohmyzsh="mate ~/.oh-my-zsh"

# Darken the autosuggest text color.
# Define using xterm-256 color code.
#
# See also:
# - https://stackoverflow.com/questions/47310537
# - https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
#
# This works well in combo with Dracula theme.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
