#!/usr/bin/env bash

koopa::update_perlbrew() { # {{{1
    # """
    # Update Perlbrew.
    # @note Updated 2020-07-30.
    # """
    koopa::is_installed perlbrew || return 0
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::h1 'Updating Perlbrew.'
    perlbrew self-upgrade
    return 0
}

