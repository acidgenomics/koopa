#!/usr/bin/env bash

# [2021-05-27] Linux success.
# [2021-05-27] macOS success.

koopa::install_anaconda() { # {{{1
    # """
    # Install Anaconda.
    # @note Updated 2021-05-25.
    # """
    koopa::install_app \
        --name='anaconda' \
        --name-fancy='Anaconda' \
        --no-link \
        "$@"
    return 0
}

koopa:::install_anaconda() { # {{{1
    # """
    # Install full Anaconda distribution.
    # @note Updated 2021-05-22.
    # """
    local arch koopa_prefix name name2 os_type prefix py_major_version
    local py_version script url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='anaconda'
    name2="$(koopa::capitalize "$name")"
    arch="$(koopa::arch)"
    koopa_prefix="$(koopa::prefix)"
    os_type="$(koopa::os_type)"
    case "$os_type" in
        darwin*)
            os_type='MacOSX'
            ;;
        linux*)
            os_type='Linux'
            ;;
        *)
            koopa::stop "'${os_type}' is not supported."
            ;;
    esac
    py_version="$(koopa::variable 'python')"
    py_major_version="$(koopa::major_version "$py_version")"
    script="${name2}${py_major_version}-${version}-${os_type}-${arch}.sh"
    url="https://repo.${name}.com/archive/${script}"
    koopa::download "$url"
    bash "$script" -bf -p "$prefix"
    koopa::ln \
        "${koopa_prefix}/etc/conda/condarc" \
        "${prefix}/.condarc"
    return 0
}
