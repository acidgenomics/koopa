#!/usr/bin/env bash

# FIXME Rework using dict approach.
koopa:::linux_install_julia_binary() { # {{{1
    # """
    # Install Julia (from binary).
    # @note Updated 2021-10-22.
    # @seealso
    # - https://julialang.org/downloads/
    # - https://julialang.org/downloads/platform/
    # """
    local arch file minor_version name os prefix subdir url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='julia'
    arch="$(koopa::arch)"
    os='linux'
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name}-${version}-${os}-${arch}.tar.gz"
    case "$arch" in
        'x86'*)
            subdir='x86'
            ;;
        *)
            subdir="$arch"
            ;;
    esac
    url="https://julialang-s3.julialang.org/bin/${os}/${subdir}/\
${minor_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::rm 'LICENSE.md'
    koopa::mkdir "$prefix"
    koopa::cp . "$prefix"
    return 0
}
