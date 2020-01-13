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

if [[ ! -d "$ZSH" ]]
then
    install-oh-my-zsh "$ZSH"
fi

CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTION="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="yyyy-mm-dd"
HYPHEN_INSENSITIVE="true"
ZSH_DISABLE_COMPFIX="true"
ZSH_THEME=""

# Standard plugins can be found in '~/.oh-my-zsh/plugins/'.
# Custom plugins may be added to '~/.oh-my-zsh/custom/plugins/'.

plugins=(
    # autojump
    # bundler
    # cabal
    # common-aliases
    # gem
    # gpg-agent
    # npm
    # pylint
    # python
    # rails
    # ruby
    # rvm
    colored-man-pages
    command-not-found
    cpanm
    dircycle
    dirhistory
    docker
    git
    last-working-dir
    perl
    pip
    rsync
    tmux
    vi-mode
)

if _koopa_is_fedora
then
    plugins+=(
        dnf
        yum
    )
elif _koopa_is_macos
then
    plugins+=(
        brew
        osx
        vscode
    )
fi

source "${ZSH}/oh-my-zsh.sh"
