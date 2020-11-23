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

# FIXME DISABLING THESE, AS IN PLACE CONDA UPDATES CAN BE PROBLEMATIC.

# shellcheck disable=SC2120
koopa::update_conda() { # {{{1
    # """
    # Update Conda.
    # @note Updated 2020-11-18.
    # """
    local force
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::conda_prefix)"
    koopa::assert_is_dir "$prefix"
    if [[ "$force" -eq 0 ]]
    then
        if koopa::is_anaconda
        then
            koopa::note 'Update not supported for Anaconda.'
            return 0
        fi
        if koopa::is_current_version conda
        then
            koopa::note 'Conda is up to date.'
            return 0
        fi
    fi
    koopa::h1 "Updating Conda at '${prefix}'."
    conda="${prefix}/condabin/conda"
    koopa::assert_is_file "$conda"
    (
        "$conda" update --yes --name='base' --channel='defaults' conda
        "$conda" update --yes --name='base' --channel='defaults' --all
        # > "$conda" clean --yes --tarballs
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::delete_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}

koopa::update_conda_envs() { # {{{1
    local conda conda_prefix envs prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed conda
    conda_prefix="$(koopa::conda_prefix)"
    koopa::assert_is_dir "$conda_prefix"
    conda="${conda_prefix}/condabin/conda"
    koopa::assert_is_file conda
    readarray -t envs <<< "$( \
        find "${conda_prefix}/envs" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -print \
            | sort \
    )"
    if ! koopa::is_array_non_empty "${envs[@]}"
    then
        koopa::note 'Failed to detect any conda environments.'
        return 0
    fi
    # shellcheck disable=SC2119
    koopa::update_conda
    koopa::h1 "Updating ${#envs[@]} environments at '${conda_prefix}'."
    for prefix in "${envs[@]}"
    do
        koopa::h2 "Updating '${prefix}'."
        "$conda" update -y --prefix="$prefix" --all
    done
    # > "$conda" clean --yes --tarballs
    koopa::sys_set_permissions -r "$conda_prefix"
    return 0
}
