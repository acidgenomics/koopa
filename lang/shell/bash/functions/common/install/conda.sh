#!/usr/bin/env bash

koopa::install_anaconda() { # {{{1
    # """
    # Install Anaconda.
    # @note Updated 2021-05-16.
    # """
    koopa::install_app \
        --name='anaconda' \
        --name-fancy='Anaconda' \
        "$@"
    return 0
}

koopa::install_conda() { # {{{1
    # """
    # Install Conda.
    # @note Updated 2021-05-16.
    # """
    koopa::install_miniconda "$@"
    return 0
}

koopa::install_miniconda() { # {{{1
    # """
    # Install Miniconda.
    # @note Updated 2021-05-16.
    # """
    koopa::install_app \
        --name='conda' \
        --name-fancy='Miniconda' \
        --installer='miniconda' \
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

koopa:::install_miniconda() { # {{{1
    # """
    # Install Miniconda.
    # @note Updated 2021-05-16.
    #
    # NOTE Consider adding install support for mamba into base environment.
    # This currently can cause dependency changes, so avoid for the moment.
    # > conda install mamba -n base -c conda-forge
    # """
    local arch koopa_prefix name name2 os_type prefix py_major_version
    local py_version script url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='miniconda'
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
    while (("$#"))
    do
        case "$1" in
            --py-version=*)
                py_version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    py_major_version="$(koopa::major_version "$py_version")"
    py_version="$(koopa::major_minor_version "$py_version")"
    py_version="$(koopa::gsub '\.' '' "$py_version")"
    script="${name2}${py_major_version}-py${py_version}_${version}-\
${os_type}-${arch}.sh"
    url="https://repo.continuum.io/${name}/${script}"
    koopa::download "$url"
    bash "$script" -bf -p "$prefix"
    koopa::ln \
        "${koopa_prefix}/etc/conda/condarc" \
        "${prefix}/.condarc"
    return 0
}
