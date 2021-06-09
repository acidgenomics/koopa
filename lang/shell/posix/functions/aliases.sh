#!/bin/sh

_koopa_alias_broot() { # {{{1
    # """
    # Broot 'br' alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'br' && unalias 'br'
    _koopa_activate_broot
    br "$@"
}

_koopa_alias_bucket() { # {{{1
    # """
    # Today bucket alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    prefix="${HOME:?}/today"
    [ -d "$prefix" ] || return 1
    cd "$prefix" || return 1
    ls
}

_koopa_alias_conda() { # {{{1
    # """
    # Conda alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'conda' && unalias 'conda'
    _koopa_activate_conda
    conda "$@"
}

_koopa_alias_doom_emacs() { # {{{1
    # """
    # Doom Emacs.
    # @note Updated 2021-06-08.
    # """
    local prefix
    prefix="$(_koopa_doom_emacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_alert_is_not_installed 'Doom Emacs' "$prefix"
        return 1
    fi
    emacs --with-profile 'doom' "$@"
}

_koopa_alias_emacs() { # {{{1
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2021-06-08.
    # """
    local prefix
    prefix="${HOME:?}/.emacs.d"
    if [ ! -f "${prefix}/chemacs.el" ]
    then
        _koopa_alert_is_not_installed 'Chemacs' "$prefix"
        return 1
    fi
    _koopa_is_installed 'emacs' || return 1
    if [ -f "${HOME:?}/.terminfo/78/xterm-24bit" ]
    then
        TERM='xterm-24bit' emacs --no-window-system "$@"
    else
        emacs --no-window-system "$@"
    fi
}

_koopa_alias_emacs_vanilla() { # {{{1
    # """
    # Vanilla Emacs alias.
    # @note Updated 2021-06-08.
    # """
    emacs --no-init-file --no-window-system "$@"
}

_koopa_alias_fzf() { # {{{1
    # """
    # FZF alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'fzf' && unalias 'fzf'
    _koopa_activate_fzf
    fzf "$@"
}

_koopa_alias_k() { # {{{1
    # """
    # Koopa 'k' shortcut alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -eq 0 ] || return 1
    cd "$(_koopa_koopa_prefix)" || return 1
}

_koopa_alias_nvim_fzf() { # {{{1
    # """
    # Pipe FZF output to Neovim.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed 'fzf' 'nvim' || return 1
    nvim "$(fzf)"
}

_koopa_alias_nvim_vanilla() { # {{{1
    # """
    # Vanilla Neovim.
    # @note Updated 2021-06-08.
    # """
    _koopa_is_installed 'nvim' || return 1
    nvim -u 'NONE' "$@"
}

# NOTE This is not currently loaded during activation.
_koopa_alias_perl() { #{{{1
    # """
    # Perl alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'perl' && unalias 'perl'
    _koopa_activate_perl_packages
    perl "$@"
}

_koopa_alias_perlbrew() { # {{{1
    # """
    # Perlbrew alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'perlbrew' && unalias 'perlbrew'
    _koopa_activate_perlbrew
    perlbrew "$@"
}

_koopa_alias_pipx() { # {{{1
    # """
    # pipx alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'pipx' && unalias 'pipx'
    _koopa_activate_pipx
    pipx "$@"
}

_koopa_alias_pyenv() { # {{{1
    # """
    # pyenv alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'pyenv' && unalias 'pyenv'
    _koopa_activate_pyenv
    pyenv "$@"
}

_koopa_alias_rbenv() { # {{{1
    # """
    # rbenv alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'rbenv' && unalias 'rbenv'
    _koopa_activate_rbenv
    rbenv "$@"
}

_koopa_alias_sha256() { # {{{1
    # """
    # sha256 alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_installed 'shasum' || return 1
    shasum -a 256 "$@"
}

_koopa_alias_spacemacs() { # {{{1
    # """
    # Spacemacs.
    # @note Updated 2021-06-08.
    # """
    local prefix
    prefix="$(_koopa_spacemacs_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_alert_is_not_installed 'Spacemacs' "$prefix"
        return 1
    fi
    emacs --with-profile 'spacemacs' "$@"
}

_koopa_alias_spacevim() { # {{{1
    # """
    # SpaceVim alias.
    # @note Updated 2021-06-08.
    # """
    local gvim prefix vim vimrc
    vim='vim'
    if _koopa_is_macos
    then
        gvim='/Applications/MacVim.app/Contents/bin/gvim'
        if [ -x "$gvim" ]
        then
            vim="$gvim"
        fi
    fi
    prefix="$(_koopa_spacevim_prefix)"
    vimrc="${prefix}/vimrc"
    if [ ! -f "$vimrc" ]
    then
        _koopa_alert_is_not_installed 'SpaceVim' "$vimrc"
        return 1
    fi
    _koopa_is_installed 'vim' || return 1
    _koopa_is_alias 'vim' && unalias 'vim'
    "$vim" -u "$vimrc" "$@"
}

_koopa_alias_tar_c() { # {{{1
    # """
    # Compress with tar alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_installed 'tar' || return 1
    tar -czvf "$@"
}

_koopa_alias_tar_x() { # {{{1
    # """
    # Compress with tar alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_installed 'tar' || return 1
    tar -xzvf "$@"
}

_koopa_alias_today() { # {{{1
    # """
    # Today alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed 'date' || return 1
    date '+%Y-%m-%d'
}

_koopa_alias_vim_fzf() { # {{{1
    # """
    # Pipe FZF output to Vim.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed 'fzf' 'vim' || return 1
    vim "$(fzf)"
}

_koopa_alias_vim_vanilla() { # {{{1
    # """
    # Vanilla Vim.
    # @note Updated 2021-06-08.
    # """
    _koopa_is_installed 'vim' || return 1
    vim -i 'NONE' -u 'NONE' -U 'NONE' "$@"
}

_koopa_alias_week() { # {{{1
    # """
    # Numerical week alias.
    # @note Updated 2021-06-08.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed 'date' || return 1
    date '+%V'
}

_koopa_alias_zoxide() { # {{{1
    # """
    # Zoxide alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'z' && unalias 'z'
    _koopa_activate_zoxide
    z "$@"
}
