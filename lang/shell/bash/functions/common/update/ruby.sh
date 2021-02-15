#!/usr/bin/env bash

koopa::update_ruby_packages() {  # {{{1
    # """
    # Update Ruby packages.
    # @note Updated 2021-02-15.
    # """
    local name_fancy
    name_fancy='Ruby'
    koopa::update_start "$name_fancy"
    koopa::assert_is_installed gem
    gem update --system
    koopa::install_ruby_packages "$@"
    koopa::update_success "$name_fancy"
    return 0
}
