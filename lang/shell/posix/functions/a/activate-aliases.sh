#!/bin/sh

_koopa_activate_aliases() {
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2023-03-11.
    # """
    _koopa_activate_coreutils_aliases
    alias ......='cd ../../../../../'
    alias .....='cd ../../../../'
    alias ....='cd ../../../'
    alias ...='cd ../../'
    alias ..='cd ..'
    alias :q='exit'
    alias R='R --no-restore --no-save --quiet'
    alias asdf='_koopa_alias_asdf'
    alias black='black --line-length=79'
    alias br-size='br --sort-by-size'
    alias br='_koopa_alias_broot'
    alias c='clear'
    alias cls='_koopa_alias_colorls'
    alias cm='chezmoi'
    # Defining this conditionally in POSIX header instead.
    # > alias conda='_koopa_alias_mamba'
    alias d='clear; cd -; l'
    alias doom-emacs='_koopa_doom_emacs'
    alias e='exit'
    alias emacs-vanilla='_koopa_alias_emacs_vanilla'
    alias emacs='_koopa_alias_emacs'
    # Consider including '--hidden'.
    alias fd='fd --case-sensitive --no-ignore'
    alias fvim='vim "$(fzf)"'
    alias g='git'
    alias glances='_koopa_alias_glances'
    alias h='history'
    alias j='z'
    alias k='_koopa_alias_k'
    alias kb='_koopa_alias_kb'
    alias kdev='_koopa_alias_kdev'
    alias kp='_koopa_alias_kp'
    alias l.='l -d .*'
    alias l1='l -1'
    alias l='_koopa_alias_l'
    alias la='l -a'
    alias lh='l | head'
    alias ll='la -l'
    alias lt='l | tail'
    # Defining this conditionally in POSIX header instead.
    # > alias mamba='_koopa_alias_mamba'
    alias nvim-fzf='_koopa_alias_nvim_fzf'
    alias nvim-vanilla='_koopa_alias_nvim_vanilla'
    alias prelude-emacs='_koopa_prelude_emacs'
    alias pyenv='_koopa_alias_pyenv'
    alias q='exit'
    alias radian='radian --no-restore --no-save --quiet'
    alias rbenv='_koopa_alias_rbenv'
    # Add '--binary' and '--hidden' here to make rg behave like 'grep -r'.
    alias rg='rg --case-sensitive --no-ignore'
    alias ronn='ronn --roff'
    alias sha256='_koopa_alias_sha256'
    alias spacemacs='_koopa_spacemacs'
    alias spacevim='_koopa_spacevim'
    alias tmux-vanilla='_koopa_alias_tmux_vanilla'
    alias today='_koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias vim-fzf='_koopa_alias_vim_fzf'
    alias vim-vanilla='_koopa_alias_vim_vanilla'
    alias week='_koopa_alias_week'
    alias z='_koopa_alias_zoxide'
    # Keep these at the end to allow the user to override our defaults.
    # shellcheck source=/dev/null
    [ -f "${HOME:?}/.aliases" ] && . "${HOME:?}/.aliases"
    # shellcheck source=/dev/null
    [ -f "${HOME:?}/.aliases-private" ] && . "${HOME:?}/.aliases-private"
    return 0
}
