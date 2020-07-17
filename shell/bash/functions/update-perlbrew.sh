#!/usr/bin/env bash

koopa::update_perlbrew() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::exit_if_not_installed perlbrew
    koopa::assert_has_no_envs
    koopa::h1 'Updating Perlbrew.'
    perlbrew self-upgrade
    return 0
}

