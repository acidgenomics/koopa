#!/usr/bin/env bash

_koopa_activate_aliases() {
    _koopa_is_interactive || return 0
    _koopa_activate_coreutils_aliases
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local xdg_data_home
    xdg_data_home="$(_koopa_xdg_data_home)"
    alias ......='cd ../../../../../'
    alias .....='cd ../../../../'
    alias ....='cd ../../../'
    alias ...='cd ../../'
    alias ..='cd ..'
    alias :q='exit'
    alias c='clear'
    alias d='clear; cd -; l'
    alias e='exit'
    alias g='git'
    alias h='history'
    alias k='_koopa_alias_k'
    alias kb='_koopa_alias_kb'
    alias kbs='_koopa_alias_kbs'
    alias kdev='_koopa_alias_kdev'
    alias l='_koopa_alias_l'
    alias l.='l -d .*'
    alias l1='ls -1'
    alias la='l -a'
    alias lh='l | head'
    alias ll='l -l'
    alias lt='l | tail'
    alias q='exit'
    alias realcd='_koopa_alias_realcd'
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias venv='_koopa_alias_venv'
    alias week='_koopa_alias_week'
    if [[ -x "${bin_prefix}/asdf" ]]
    then
        alias asdf='_koopa_activate_asdf; asdf'
    fi
    if [[ -x "${bin_prefix}/black" ]]
    then
        alias black='black --line-length=79'
    fi
    if [[ -x "${bin_prefix}/broot" ]]
    then
        alias br='_koopa_activate_broot; br'
        alias br-size='br --sort-by-size'
    fi
    if [[ -x "${bin_prefix}/chezmoi" ]]
    then
        alias cm='chezmoi'
    fi
    if [[ -x "${bin_prefix}/colorls" ]]
    then
        alias cls='_koopa_alias_colorls'
    fi
    if [[ -x "${bin_prefix}/conda" ]]
    then
        alias conda='_koopa_activate_conda; conda'
    fi
    if [[ -x '/usr/local/bin/emacs' ]] || \
        [[ -x '/usr/bin/emacs' ]] || \
        [[ -x "${bin_prefix}/emacs" ]]
    then
        alias emacs='_koopa_alias_emacs'
        alias emacs-vanilla='_koopa_alias_emacs_vanilla'
        if [[ -d "${xdg_data_home}/doom" ]]
        then
            alias doom-emacs='_koopa_doom_emacs'
        fi
        if [[ -d "${xdg_data_home}/prelude" ]]
        then
            alias prelude-emacs='_koopa_prelude_emacs'
        fi
        if [[ -d "${xdg_data_home}/spacemacs" ]]
        then
            alias spacemacs='_koopa_spacemacs'
        fi
    fi
    if [[ -x "${bin_prefix}/fd" ]]
    then
        alias fd='fd --absolute-path --ignore-case --no-ignore'
    fi
    if [[ -x "${bin_prefix}/glances" ]]
    then
        alias glances='_koopa_alias_glances'
    fi
    if [[ -x "${bin_prefix}/nvim" ]]
    then
        alias nvim-vanilla='_koopa_alias_nvim_vanilla'
        if [[ -x "${bin_prefix}/fzf" ]]
        then
            alias nvim-fzf='_koopa_alias_nvim_fzf'
        fi
    fi
    if [[ -x "${bin_prefix}/pyenv" ]]
    then
        alias pyenv='_koopa_activate_pyenv; pyenv'
    fi
    if [[ -x "${bin_prefix}/python3" ]]
    then
        alias python3-dev='PYTHONPATH="$(pwd)" python3'
    fi
    if [[ -x '/usr/local/bin/R' ]] || [[ -x '/usr/bin/R' ]]
    then
        alias R='R --no-restore --no-save --quiet'
    fi
    if [[ -x "${bin_prefix}/pyenv" ]]
    then
        alias radian='radian --no-restore --no-save --quiet'
    fi
    if [[ -x "${bin_prefix}/rbenv" ]]
    then
        alias rbenv='_koopa_activate_rbenv; rbenv'
    fi
    if [[ -x '/usr/bin/shasum' ]]
    then
        alias sha256='shasum -a 256'
    fi
    if [[ -x "${bin_prefix}/tmux" ]]
    then
        alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    fi
    if [[ -x "${bin_prefix}/vim" ]]
    then
        alias vim-vanilla='_koopa_alias_vim_vanilla'
        if [[ -x "${bin_prefix}/fzf" ]]
        then
            alias vim-fzf='_koopa_alias_vim_fzf'
        fi
        if [[ -d "${xdg_data_home}/spacevim" ]]
        then
            alias spacevim='_koopa_spacevim'
        fi
    fi
    if [[ -x "${bin_prefix}/walk" ]]
    then
        alias lk='_koopa_walk'
    fi
    if [[ -x "${bin_prefix}/zoxide" ]]
    then
        alias z='_koopa_activate_zoxide; __zoxide_z'
        alias j='z'
    fi
    if [[ -f "${HOME:?}/.aliases" ]]
    then
        source "${HOME:?}/.aliases"
    fi
    if [[ -f "${HOME:?}/.aliases-private" ]]
    then
        source "${HOME:?}/.aliases-private"
    fi
    if [[ -f "${HOME:?}/.aliases-work" ]]
    then
        source "${HOME:?}/.aliases-work"
    fi
    return 0
}
