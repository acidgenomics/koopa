#!/usr/bin/env bash

# [2021-05-27] Linux success.
# [2021-05-27] macOS success.

koopa::install_conda() { # {{{1
    koopa::install_miniconda "$@"
}

koopa::install_miniconda() { # {{{1
    koopa::install_app \
        --installer='miniconda' \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        "$@"
}

koopa:::install_miniconda() { # {{{1
    # """
    # Install Miniconda, including Mamba in base environment.
    # @note Updated 2021-07-28.
    # """
    local arch koopa_prefix mamba mamba_version name name2 os_type prefix
    local py_major_version py_version script url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='miniconda'
    name2="$(koopa::capitalize "$name")"
    arch="$(koopa::arch)"
    koopa_prefix="$(koopa::koopa_prefix)"
    mamba=0
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
            --no-mamba)
                mamba=0
                shift 1
                ;;
            --py-version=*)
                py_version="${1#*=}"
                shift 1
                ;;
            --with-mamba)
                mamba=1
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
    # Install mamba inside of conda base environment, if desired.
    if [[ "$mamba" -eq 1 ]]
    then
        koopa::alert "Installing mamba inside conda at '${prefix}'."
        koopa::activate_conda "$prefix"
        mamba_version="$(koopa::variable 'conda-mamba')"
        conda install \
            --yes \
            --name='base' \
            --channel='conda-forge' \
            "mamba==${mamba_version}"
        koopa::deactivate_conda
    fi
    return 0
}

koopa::uninstall_conda() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --no-link \
        "$@"
}
