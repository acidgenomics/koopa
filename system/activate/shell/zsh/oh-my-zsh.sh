#!/usr/bin/env zsh
# shellcheck disable=SC1090,SC2034,SC2039

# oh-my-zsh configuration
# https://github.com/robbyrussell/oh-my-zsh

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH}/custom"

# Install oh-my-zsh automatically, if necessary.
if [[ ! -d "$ZSH" ]]
then
    printf "Installing oh-my-zsh at %s.\n" "$ZSH"
    install-oh-my-zsh
fi

# Ignore warning about insecure directories identified by compfix.
ZSH_DISABLE_COMPFIX="true"

# Set name of the theme to load.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# Set to empty string when using pure prompt.
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Enable automatic upgrade, without prompting.
DISABLE_UPDATE_PROMPT=true

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins_dir="${ZSH_CUSTOM}/plugins"

if [[ ! -d "${plugins_dir}/zsh-autosuggestions" ]]
then
    printf "Installing zsh-autosuggestions.\n"
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "${plugins_dir}/zsh-autosuggestions"
fi

plugins=(
  git
  zsh-autosuggestions
  # zsh-syntax-highlighting
)

unset -v plugins_dir

source "${ZSH}/oh-my-zsh.sh"



# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Dark the autosuggest text color.
# Define using xterm-256 color code.
# https://stackoverflow.com/questions/47310537
# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
# This works well in combo with Dracula theme.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"

