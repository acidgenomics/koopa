#!/usr/bin/env bash
# shellcheck disable=SC2039

koopa::activate_conda_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2020-07-14.
    #
    # Designed to work inside calling scripts and/or subshells.
    #
    # Currently, the conda activation script returns a 'conda()' function in
    # the current shell that doesn't propagate to subshells. This function
    # attempts to rectify the current situation.
    #
    # Note that the conda activation script currently has unbound variables
    # (e.g. PS1), that will cause this step to fail unless we temporarily
    # disable unbound variable checks.
    #
    # Alternate approach:
    # > eval "$(conda shell.bash hook)"
    #
    # See also:
    # - https://github.com/conda/conda/issues/7980
    # - https://stackoverflow.com/questions/34534513
    # """
    local conda_prefix env env_dir nounset
    koopa::assert_has_args_eq "$#" 1
    env="${1:?}"
    conda_prefix="$(koopa::conda_prefix)"
    # Locate latest version automatically, if necessary.
    if ! koopa::str_match "$env" '@'
    then
        koopa::assert_is_installed find
        env_dir="$( \
            find "${conda_prefix}/envs" \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
                -name "${env}@*" \
                -print \
            | sort \
            | tail -n 1 \
        )"
        if [[ ! -d "$env_dir" ]]
        then
            koopa::stop "Failed to locate '${env}' conda environment."
        fi
        env="$(basename "$env_dir")"
    fi
    nounset="$(koopa::boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +u
    if ! type conda | grep -q conda.sh
    then
        # shellcheck source=/dev/null
        . "${conda_prefix}/etc/profile.d/conda.sh"
    fi
    conda activate "$env"
    [[ "$nounset" -eq 1 ]] && set -u
    return 0
}

koopa::conda_create_bioinfo_envs() { # {{{1
    # """
    # Create Conda bioinformatics environments.
    # @note Updated 2020-07-30.
    # """
    local all aligners chipseq data_mining env envs file_formats methylation \
        quality_control rnaseq trimming variation version workflows
    koopa::assert_is_installed conda
    all=0
    aligners=0
    chipseq=0
    data_mining=0
    file_formats=0
    methylation=0
    quality_control=0
    rnaseq=0
    trimming=0
    variation=0
    workflows=0
    # Set recommended defaults, if necessary.
    if [[ "$#" -eq 0 ]]
    then
        aligners=1
        chipseq=1
        data_mining=1
        file_formats=1
        rnaseq=1
        workflows=1
    fi
    while (("$#"))
    do
        case "$1" in
            --all)
                all=1
                shift 1
                ;;
            --aligners)
                aligners=1
                shift 1
                ;;
            --chipseq|--chip-seq)
                chipseq=1
                shift 1
                ;;
            --data-mining)
                data_mining=1
                shift 1
                ;;
            --file-formats)
                file_formats=1
                shift 1
                ;;
            --methylation)
                methylation=1
                shift 1
                ;;
            --qc|quality-control)
                quality_control=1
                shift 1
                ;;
            --rnaseq|--rna-seq)
                rnaseq=1
                shift 1
                ;;
            --trimming)
                trimming=1
                shift 1
                ;;
            --variation)
                variation=1
                shift 1
                ;;
            --workflows)
                workflows=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Installing conda environments for bioinformatics.'
    envs=()
    if [[ "$all" -eq 1 ]]
    then
        aligners=1
        chipseq=1
        data_mining=1
        file_formats=1
        methylation=1
        quality_control=1
        rnaseq=1
        trimming=1
        variation=1
        workflows=1
        envs+=('igvtools')
    fi
    if [[ "$aligners" -eq 1 ]]
    then
        # Consider: minimap2, novoalign
        envs+=(
            'bowtie2'
            'bwa'
            'hisat2'
            'rsem'
            'star'
        )
        if koopa::is_linux
        then
            envs+=('bwa-mem2')
        fi
    fi
    if [[ "$chipseq" -eq 1 ]]
    then
        envs+=(
            'chromhmm'
            'deeptools'
            'genrich'
            'homer'
            'macs2'
            'sicer2'
        )
    fi
    if [[ "$data_mining" -eq 1 ]]
    then
        envs+=('entrez-direct' 'sra-tools')
    fi
    if [[ "$file_formats" -eq 1 ]]
    then
        envs+=(
            'bamtools'
            'bcftools'
            'bedtools'
            'bioawk'
            'gffutils'
            'htslib'
            'sambamba'
            'samblaster'
            'samtools'
            'seqtk'
        )
        if koopa::is_linux
        then
            envs+=('biobambam')
        fi
    fi
    if [[ "$methylation" -eq 1 ]]
    then
        envs+=('bismark')
    fi
    if [[ "$quality_control" -eq 1 ]]
    then
        envs+=(
            'fastqc'
            'kraken'
            'multiqc'
            'qualimap'
        )
    fi
    if [[ "$rnaseq" -eq 1 ]]
    then
        # Consider: rapmap
        envs+=('kallisto' 'salmon')
    fi
    if [[ "$trimming" -eq 1 ]]
    then
        envs+=('atropos' 'trimmomatic')
    fi
    if [[ "$variation" -eq 1 ]]
    then
        envs+=(
            'ericscript'
            'oncofuse'
            'peddy'
            'pizzly'
            'squid'
            'star-fusion'
            'vardict'
        )
        if koopa::is_linux
        then
            envs+=('arriba')
        fi
    fi
    if [[ "$workflows" -eq 1 ]]
    then
        # Consider: cromwell
        envs+=(
            'fgbio'
            'gatk4'
            'jupyterlab'
            'nextflow'
            'picard'
            'snakemake'
        )
    fi
    for i in ${!envs[*]}
    do
        env="${envs[$i]}"
        version="$(koopa::variable "$env")"
        envs[$i]="${env}@${version}"
    done
    koopa::conda_create_env "${envs[@]}"
    return 0
}

koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2020-07-21.
    # """
    local conda_prefix force env env_name pos prefix
    koopa::assert_has_args "$#"
    force=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    koopa::activate_conda
    koopa::assert_is_installed conda
    conda_prefix="$(koopa::conda_prefix)"
    for env in "$@"
    do
        env="${env//@/=}"
        # Get supported version.
        if ! koopa::str_match "$env" '='
        then
            koopa::stop "Version is required. Specify as 'NAME=VERSION'."
        fi
        env_name="${env//=/@}"
        prefix="${conda_prefix}/envs/${env_name}"
        if [[ -d "$prefix" ]]
        then
            if [[ "$force" -eq 1 ]]
            then
                conda remove --name "$env_name" --all
            else
                koopa::note "Conda environment '${env_name}' exists."
                continue
            fi
        fi
        koopa::info "Creating '${env_name}' conda environment."
        conda create --name="$env_name" --quiet --yes "$env"
        koopa::sys_set_permissions -r "$prefix"
    done
    return 0
}

koopa::conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2019-06-30.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed conda
    x="$(conda env list --json)"
    koopa::print "$x"
    return 0
}

koopa::conda_env_prefix() { # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2020-07-05.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa::conda_env_prefix 'deeptools'
    # """
    local env_dir env_list env_name x
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed conda
    env_name="${1:?}"
    [[ -n "$env_name" ]] || return 1
    env_list="${2:-$(koopa::conda_env_list)}"
    env_list="$(koopa::print "$env_list" | grep "$env_name")"
    if [[ -z "$env_list" ]]
    then
        koopa::stop "Failed to detect prefix for '${env_name}'."
    fi
    env_dir="$( \
        koopa::print "$env_list" \
        | grep "/envs/${env_name}" \
        | head -n 1 \
    )"
    x="$(koopa::print "$env_dir" | sed -E 's/^.*"(.+)".*$/\1/')"
    koopa::print "$x"
    return 0
}

koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2020-06-30.
    # """
    local arg
    koopa::assert_has_args "$#"
    koopa::activate_conda
    koopa::assert_is_installed conda
    for arg in "$@"
    do
        conda remove --yes --name="$arg" --all
    done
    return 0
}

koopa::install_conda() { # {{{1
    # """
    # Install Conda (or Anaconda).
    # @note Updated 2020-07-30.
    #
    # Python 3.8 is currently buggy for Miniconda.
    # `conda env list` will return multiprocessing error.
    # https://github.com/conda/conda/issues/9589
    # """
    local anaconda name_fancy ostype script tmp_dir url version
    koopa::is_installed conda && return 0
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
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

# shellcheck disable=SC2120
koopa::update_conda() { # {{{1
    # """
    # Update Conda.
    # @note Updated 2020-07-30.
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
        koopa::is_current_version conda && return 0
    fi
    koopa::h1 "Updating Conda at '${prefix}'."
    conda="${prefix}/condabin/conda"
    koopa::assert_is_file "$conda"
    (
        "$conda" update --yes --name='base' --channel='defaults' conda
        "$conda" update --yes --name='base' --channel='defaults' --all
        # > "$conda" clean --yes --tarballs
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::remove_broken_symlinks "$prefix"
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

