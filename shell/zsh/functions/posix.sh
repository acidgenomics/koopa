#!/usr/bin/env zsh

koopa::activate_starship() { # {{{
    _koopa_activate_starship "$@"
}

koopa::add_to_fpath_end() { # {{{1
    _koopa_add_to_fpath_end "$@"
}

koopa::add_to_fpath_start() { # {{{1
    _koopa_add_to_fpath_start "$@"
}

koopa::dotfiles_prefix() { # {{{1
    _koopa_dotfiles_prefix "$@"
}

koopa::is_installed() { # {{{1
    _koopa_is_installed "$@"
}

koopa::remove_from_fpath() { # {{{1
    _koopa_remove_from_fpath "$@"
}

koopa::prefix() { # {{{1
    _koopa_prefix "$@"
}

koopa::prompt() { # {{{1
    _koopa_prompt "$@"
}

koopa::warning() { # {{{1
    _koopa_warning "$@"
}
