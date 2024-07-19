#!/bin/sh

_koopa_activate_aliases() {
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2024-06-15.
    # """
    _koopa_is_interactive || return 0
    _koopa_activate_coreutils_aliases
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_xdg_data_home="$(_koopa_xdg_data_home)"
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
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias week='_koopa_alias_week'
    # Application aliases ------------------------------------------------------
    # asdf.
    if [ -x "${__kvar_bin_prefix}/asdf" ]
    then
        alias asdf='_koopa_activate_asdf; asdf'
    fi
    # black.
    if [ -x "${__kvar_bin_prefix}/black" ]
    then
        alias black='black --line-length=79'
    fi
    # broot.
    if [ -x "${__kvar_bin_prefix}/broot" ]
    then
        alias br='_koopa_activate_broot; br'
        alias br-size='br --sort-by-size'
    fi
    # chezmoi.
    if [ -x "${__kvar_bin_prefix}/chezmoi" ]
    then
        alias cm='chezmoi'
    fi
    # colorls.
    if [ -x "${__kvar_bin_prefix}/colorls" ]
    then
        alias cls='_koopa_alias_colorls'
    fi
    # conda.
    if [ -x "${__kvar_bin_prefix}/conda" ]
    then
        alias conda='_koopa_activate_conda; conda'
    fi
    # emacs.
    if [ -x '/usr/local/bin/emacs' ] || \
        [ -x '/usr/bin/emacs' ] || \
        [ -x "${__kvar_bin_prefix}/emacs" ]
    then
        alias emacs='_koopa_alias_emacs'
        alias emacs-vanilla='_koopa_alias_emacs_vanilla'
        if [ -d "${__kvar_xdg_data_home}/doom" ]
        then
            alias doom-emacs='_koopa_doom_emacs'
        fi
        if [ -d "${__kvar_xdg_data_home}/prelude" ]
        then
            alias prelude-emacs='_koopa_prelude_emacs'
        fi
        if [ -d "${__kvar_xdg_data_home}/spacemacs" ]
        then
            alias spacemacs='_koopa_spacemacs'
        fi
    fi
    # fd-find.
    if [ -x "${__kvar_bin_prefix}/fd" ]
    then
        alias fd='fd --absolute-path --ignore-case --no-ignore'
    fi
    # glances.
    if [ -x "${__kvar_bin_prefix}/glances" ]
    then
        alias glances='_koopa_alias_glances'
    fi
    # neovim.
    if [ -x "${__kvar_bin_prefix}/nvim" ]
    then
        alias nvim-vanilla='_koopa_alias_nvim_vanilla'
        if [ -x "${__kvar_bin_prefix}/fzf" ]
        then
            alias nvim-fzf='_koopa_alias_nvim_fzf'
        fi
    fi
    # pyenv.
    if [ -x "${__kvar_bin_prefix}/pyenv" ]
    then
        alias pyenv='_koopa_activate_pyenv; pyenv'
    fi
    # python.
    if [ -x "${__kvar_bin_prefix}/python3" ]
    then
        alias python3-dev='_koopa_alias_python3_dev'
    fi
    # r.
    if [ -x '/usr/local/bin/R' ] || [ -x '/usr/bin/R' ]
    then
        alias R='R --no-restore --no-save --quiet'
    fi
    # radian.
    if [ -x "${__kvar_bin_prefix}/pyenv" ]
    then
        alias radian='radian --no-restore --no-save --quiet'
    fi
    # rbenv.
    if [ -x "${__kvar_bin_prefix}/rbenv" ]
    then
        alias rbenv='_koopa_activate_rbenv; rbenv'
    fi
    # shasum.
    if [ -x '/usr/bin/shasum' ]
    then
        alias sha256='_koopa_alias_sha256'
    fi
    # tmux.
    if [ -x "${__kvar_bin_prefix}/tmux" ]
    then
        alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    fi
    # vim.
    if [ -x "${__kvar_bin_prefix}/vim" ]
    then
        alias vim-vanilla='_koopa_alias_vim_vanilla'
        if [ -x "${__kvar_bin_prefix}/fzf" ]
        then
            alias vim-fzf='_koopa_alias_vim_fzf'
        fi
        if [ -d "${__kvar_xdg_data_home}/spacevim" ]
        then
            alias spacevim='_koopa_spacevim'
        fi
    fi
    # walk.
    if [ -x "${__kvar_bin_prefix}/walk" ]
    then
        alias lk='_koopa_walk'
    fi
    # zoxide.
    if [ -x "${__kvar_bin_prefix}/zoxide" ]
    then
        alias z='_koopa_activate_zoxide; __zoxide_z'
        # Keep our legacy 'j' binding to mimic autojump.
        alias j='z'
    fi
    # User-defined aliases -----------------------------------------------------
    # Keep these at the end to allow the user to override our defaults.
    if [ -f "${HOME:?}/.aliases" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.aliases"
    fi
    if [ -f "${HOME:?}/.aliases-private" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.aliases-private"
    fi
    if [ -f "${HOME:?}/.aliases-work" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.aliases-work"
    fi
    unset -v __kvar_bin_prefix __kvar_xdg_data_home
    return 0
}
