#!/usr/bin/env bash

koopa::_install_conda() { # {{{1
    # """
    # Install Conda (or Anaconda).
    # @note Updated 2020-11-23.
    #
    # Assuming installation of Miniconda by default.
    #
    # Python 3.8 is currently buggy for Miniconda.
    # `conda env list` will return multiprocessing error.
    # https://github.com/conda/conda/issues/9589
    # """
    local anaconda name_fancy ostype script tmp_dir url version
    if koopa::is_installed conda
    then
        koopa::note 'Conda is already installed.'
        return 0
    fi
    koopa::assert_has_no_envs
    ostype="${OSTYPE:?}"
    case "$ostype" in
        darwin*)
            ostype='MacOSX'
            ;;
        linux*)
            ostype='Linux'
            ;;
        *)
            koopa::stop "'${ostype}' is not supported."
            ;;
    esac
    anaconda=0
    version=
    while (("$#"))
    do
        case "$1" in
            --anaconda)
                anaconda=1
                shift 1
                ;;
            --miniconda)
                anaconda=0
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    prefix="$(koopa::conda_prefix)"
    [[ -d "$prefix" ]] && return 0
    if [[ "$anaconda" -eq 1 ]]
    then
        [[ -z "$version" ]] && version="$(koopa::variable 'anaconda')"
        name_fancy='Anaconda'
        script="Anaconda3-${version}-${ostype}-x86_64.sh"
        url="https://repo.anaconda.com/archive/${script}"
    else
        [[ -z "$version" ]] && version="$(koopa::variable 'conda')"
        name_fancy='Miniconda'
        script="Miniconda3-py37_${version}-${ostype}-x86_64.sh"
        url="https://repo.continuum.io/miniconda/${script}"
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::mkdir "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        bash "$script" -bf -p "$prefix"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::ln "$(koopa::prefix)/os/linux/etc/conda/condarc" "${prefix}/.condarc"
    koopa::delete_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_anaconda() { # {{{1
    # """
    # Install Anaconda.
    # @note Updated 2020-10-27.
    # """
    koopa::_install_conda --anaconda "$@"
    return 0
}

koopa::install_miniconda() { # {{{1
    # """
    # Install Miniconda.
    # @note Updated 2020-10-27.
    # """
    koopa::_install_conda --miniconda "$@"
    return 0
}
