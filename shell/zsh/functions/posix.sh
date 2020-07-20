#!/usr/bin/env zsh

koopa::add_to_fpath_end() { # {{{1
    _koopa_force_add_to_fpath_end "$@"
}

koopa::add_to_fpath_start() { # {{{1
    _koopa_force_add_to_fpath_start "$@"
}

koopa::dotfiles_prefix() { # {{{1
    _koopa_dotfiles_prefix "$@"
}

koopa::force_add_to_fpath_end() { # {{{1
    _koopa_force_add_to_fpath_end "$@"
}

koopa::force_add_to_fpath_start() { # {{{1
    _koopa_force_add_to_fpath_start "$@"
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
