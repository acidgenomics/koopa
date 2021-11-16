#!/usr/bin/env bash

# FIXME Rework using dict approach.
koopa:::install_anaconda() { # {{{1
    # """
    # Install full Anaconda distribution.
    # @note Updated 2021-11-16.
    # """
    local arch file koopa_prefix name name2 os_type prefix py_major_version
    local py_version url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='anaconda'
    name2="$(koopa::capitalize "$name")"
    arch="$(koopa::arch)"
    koopa_prefix="$(koopa::koopa_prefix)"
    os_type="$(koopa::os_type)"
    case "$os_type" in
        'darwin'*)
            os_type='MacOSX'
            ;;
        'linux'*)
            os_type='Linux'
            ;;
        *)
            koopa::stop "'${os_type}' is not supported."
            ;;
    esac
    py_version="$(koopa::variable 'python')"
    py_major_version="$(koopa::major_version "$py_version")"
    file="${name2}${py_major_version}-${version}-${os_type}-${arch}.sh"
    url="https://repo.${name}.com/archive/${file}"
    koopa::download "$url" "$file"
    bash "$file" -bf -p "$prefix"
    koopa::ln \
        "${koopa_prefix}/etc/conda/condarc" \
        "${prefix}/.condarc"
    return 0
}
