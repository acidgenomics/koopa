#!/usr/bin/env zsh

koopa::add_to_fpath_end() {
    _koopa_force_add_to_fpath_end "$@"
}

koopa::add_to_fpath_start() {
    _koopa_force_add_to_fpath_start "$@"
}

koopa::dotfiles_prefix() {
    _koopa_dotfiles_prefix "$@"
}

koopa::force_add_to_fpath_end() {
    _koopa_force_add_to_fpath_end "$@"
}

koopa::force_add_to_fpath_start() {
    _koopa_force_add_to_fpath_start "$@"
}

koopa::remove_from_fpath() {
    _koopa_remove_from_fpath "$@"
}

koopa::prefix() {
    _koopa_prefix "$@"
}

koopa::warning() {
    _koopa_warning "$@"
}
