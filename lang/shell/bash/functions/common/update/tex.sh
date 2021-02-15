#!/usr/bin/env bash

koopa::update_tex() { # {{{1
    # """
    # Update TeX.
    # @note Updated 2020-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::assert_has_sudo
    koopa::h1 'Updating TeX Live.'
    sudo tlmgr update --self
    sudo tlmgr update --list
    sudo tlmgr update --all
    return 0
}
