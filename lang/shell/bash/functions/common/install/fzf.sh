#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_fzf() { # {{{1
    koopa::install_app \
        --name='fzf' \
        --name-fancy='FZF' \
        "$@"
}

koopa:::install_fzf() { # {{{1
    # """
    # Install fzf.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    koopa::activate_go
    koopa::assert_is_installed 'go'
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='fzf'
    koopa::mkdir "$prefix"
    file="${version}.tar.gz"
    url="https://github.com/junegunn/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    export FZF_VERSION="$version"
    export FZF_REVISION='tarball'
    "$make" --jobs="$jobs"
    # > "$make" test
    # This will copy fzf binary from 'target/' to 'bin/' inside tmp dir.
    # Note that this step does not copy to '/usr/bin/'.
    "$make" install
    # > ./install --help
    ./install --bin --no-update-rc
    # Following approach used in Homebrew recipe here.
    koopa::rm .[[:alnum:]]* 'src' 'target'
    koopa::cp . "$prefix"
    return 0
}
