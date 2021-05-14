#!/usr/bin/env bash

# NOTE It appears that ARM support is coming:
# Anaconda3-2021.04-Linux-aarch64.sh

koopa::install_anaconda() { # {{{1
    # """
    # Install Anaconda.
    # @note Updated 2020-10-27.
    # """
    koopa:::install_conda --anaconda "$@"
    return 0
}

koopa::install_conda() { # {{{1
    # """
    # Install Conda.
    # @note Updated 2020-11-24.
    #
    # Assuming user wants Miniconda by default.
    # """
    koopa::install_miniconda "$@"
    return 0
}

koopa::install_miniconda() { # {{{1
    # """
    # Install Miniconda.
    # @note Updated 2020-10-27.
    # """
    koopa:::install_conda --miniconda "$@"
    return 0
}

koopa:::install_conda() { # {{{1
    # """
    # Install Conda (or Anaconda).
    # @note Updated 2021-05-14.
    #
    # Assuming installation of Miniconda by default.
    #
    # NOTE Consider adding install support for mamba into base environment.
    # This currently can cause dependency changes, so avoid for the moment.
    # > conda install mamba -n base -c conda-forge
    # """
    local anaconda arch name name_fancy os_type prefix py_version script \
        tmp_dir url version
    koopa::assert_has_no_envs
    # Support for aarch64 (ARM) was added in 2021 Q1.
    arch="$(koopa::arch)"
    anaconda=0
    # Match Bioconda recommendation by default here.
    # This only applies to Miniconda, not full Anaconda.
    py_version='3.9'
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
            --py-version=*)
                py_version="${1#*=}"
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
    if [[ "$anaconda" -eq 1 ]]
    then
        name='anaconda'
        name_fancy='Anaconda'
        [[ -z "${version:-}" ]] && version="$(koopa::variable "$name")"
        script="Anaconda3-${version}-${os_type}-${arch}.sh"
        url="https://repo.anaconda.com/archive/${script}"
    else
        name='conda'
        name_fancy='Miniconda'
        [[ -z "${version:-}" ]] && version="$(koopa::variable "$name")"
        py_version="$(koopa::major_minor_version "$py_version")"
        py_version="$(koopa::gsub '\.' '' "$py_version")"
        script="Miniconda3-py${py_version}_${version}-${os_type}-${arch}.sh"
        url="https://repo.continuum.io/miniconda/${script}"
    fi
    prefix="$(koopa::app_prefix)/${name}/${version}"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "${name_fancy} is already installed at '${prefix}'."
        return 0
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
    koopa::ln \
        "$(koopa::prefix)/os/linux/etc/conda/condarc" \
        "${prefix}/.condarc"
    koopa::delete_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    koopa::link_into_opt "$prefix" 'conda'
    koopa::install_success "$name_fancy"
    koopa::alert_restart
    return 0
}
