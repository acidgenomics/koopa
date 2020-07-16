#!/usr/bin/env bash

koopa::install_autoconf() {
    koopa::install_cellar --name='autoconf' "$@"
    return 0
}

koopa::install_autojump() {
    koopa::install_cellar --name='autojump' "$@"
    return 0
}

koopa::install_singularity() {
    koopa::install_cellar --name='singularity' "$@"
    return 0
}
