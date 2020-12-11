#!/usr/bin/env bash

koopa::update_homebrew() { # {{{1
    koopa::brew_update "$@"
    return 0
}
