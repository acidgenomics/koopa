#!/bin/sh

koopa_activate_aliases() {
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2022-12-07.
    # """
    local file
    koopa_activate_coreutils_aliases
    alias ......='cd ../../../../../'
    alias .....='cd ../../../../'
    alias ....='cd ../../../'
    alias ...='cd ../../'
    alias ..='cd ..'
    alias :q='exit'
    alias R='R --no-restore --no-save --quiet'
    alias asdf='koopa_alias_asdf'
    alias black='black --line-length=79'
    alias br-size='br --sort-by-size'
    alias br='koopa_alias_broot'
    alias bucket='koopa_alias_bucket'
    alias c='clear'
    alias cls='koopa_alias_colorls'
    alias cm='chezmoi'
    # Defining this conditionally in POSIX header instead.
    # > alias conda='koopa_alias_mamba'
    alias d='clear; cd -; l'
    alias doom-emacs='koopa_doom_emacs'
    alias e='exit'
    alias emacs-vanilla='koopa_alias_emacs_vanilla'
    alias emacs='koopa_alias_emacs'
    # Consider including '--hidden'.
    alias fd='fd --case-sensitive --no-ignore'
    alias fvim='vim "$(fzf)"'
    alias g='git'
    alias glances='koopa_alias_glances'
    alias h='history'
    alias j='z'
    alias k='koopa_alias_k'
    alias kb='koopa_alias_kb'
    alias kdev='koopa_alias_kdev'
    alias kp='koopa_alias_kp'
    alias l.='l -d .*'
    alias l1='l -1'
    alias l='koopa_alias_l'
    alias la='l -a'
    alias lh='l | head'
    alias ll='la -l'
    alias lt='l | tail'
    # Defining this conditionally in POSIX header instead.
    # > alias mamba='koopa_alias_mamba'
    alias nvim-fzf='koopa_alias_nvim_fzf'
    alias nvim-vanilla='koopa_alias_nvim_vanilla'
    alias prelude-emacs='koopa_prelude_emacs'
    alias pyenv='koopa_alias_pyenv'
    alias q='exit'
    alias radian='radian --no-restore --no-save --quiet'
    alias rbenv='koopa_alias_rbenv'
    # Add '--binary' and '--hidden' here to make rg behave like 'grep -r'.
    alias rg='rg --case-sensitive --no-ignore'
    alias ronn='ronn --roff'
    alias sha256='koopa_alias_sha256'
    alias spacemacs='koopa_spacemacs'
    alias spacevim='koopa_spacevim'
    alias tmux-vanilla='koopa_alias_tmux_vanilla'
    alias today='koopa_alias_today'
    alias u='clear; cd ../; pwd; l'
    alias variable-bodies='typeset -p'
    alias variable-names='compgen -A variable | sort'
    alias vim-fzf='koopa_alias_vim_fzf'
    alias vim-vanilla='koopa_alias_vim_vanilla'
    alias week='koopa_alias_week'
    alias z='koopa_alias_zoxide'
    # Keep these at the end to allow the user to override our defaults.
    file="${HOME:?}/.aliases"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    file="${HOME:?}/.aliases-private"
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
    return 0
}