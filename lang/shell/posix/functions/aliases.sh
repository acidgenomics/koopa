#!/bin/sh

_koopa_alias_br() { # {{{1
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
    cd "$(_koopa_koopa_prefix)" || return 1
}

# NOTE This is not currently active.
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

_koopa_alias_spacevim() { # {{{1
    # """
    # SpaceVim alias.
    # @note Updated 2021-06-07.
    # """
    local prefix vimrc
    prefix="$(_koopa_spacevim_prefix)"
    vimrc="${prefix}/vimrc"
    [ -f "$vimrc" ] || return 1
    _koopa_is_installed 'vim' || return 1
    _koopa_is_alias 'vim' && unalias 'vim'
    vim -u "$vimrc" "$@"
}

_koopa_alias_today() { # {{{1
    # """
    # Today alias.
    # @note Updated 2021-06-08.
    # """
    _koopa_is_installed 'date' || return 1
    date '+%Y-%m-%d'
}

_koopa_alias_week() { # {{{1
    # """
    # Numerical week alias.
    # @note Updated 2021-06-08.
    # """
    _koopa_is_installed 'date' || return 1
    date '+%V'
}

_koopa_alias_z() { # {{{1
    # """
    # Zoxide alias.
    # @note Updated 2021-05-26.
    # """
    _koopa_is_alias 'z' && unalias 'z'
    _koopa_activate_zoxide
    z "$@"
}
