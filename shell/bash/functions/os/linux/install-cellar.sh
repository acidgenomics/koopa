#!/usr/bin/env bash

koopa::install_autoconf() {
    koopa::install_cellar --name='autoconf' "$@"
    return 0
}

koopa::install_autojump() {
    koopa::install_cellar --name='autojump' "$@"
    return 0
}

koopa::install_automake() {
    koopa::install_cellar --name="automake" "$@"
    return 0
}

koopa::install_aws_cli() {
    koopa::install_cellar \
        --name="aws-cli" \
        --name-fancy="AWS CLI" \
        --version="latest" \
        --include-dirs="bin" \
        "$@"
    return 0
}

koopa::install_bash() {
    koopa::install_cellar --name="bash" --name-fancy="Bash" "$@"
    return 0
}

koopa::install_binutils() {
    koopa::install_cellar --name="binutils" "$@"
    return 0
}

koopa::install_cmake() {
    koopa::install_cellar --name="cmake" --name-fancy="CMake" "$@"
    return 0
}

koopa::install_coreutils() {
    koopa::install_cellar --name="coreutils" "$@"
    return 0
}

koopa::install_singularity() {
    koopa::install_cellar --name='singularity' "$@"
    return 0
}
