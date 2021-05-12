#!/usr/bin/env bash

koopa::activate_conda_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2021-04-30.
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
    local conda_prefix env_name env_prefix nounset script
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed conda
    env_prefix="$(koopa::conda_env_prefix "${1:?}")"
    [[ -n "$env_prefix" ]] || return 1
    env_name="$(basename "$env_prefix")"
    nounset="$(koopa::boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +u
    if ! type conda | grep -q 'conda.sh'
    then
        conda_prefix="$(koopa::conda_prefix)"
        script="${conda_prefix}/etc/profile.d/conda.sh"
        koopa::assert_is_file "$script"
        # shellcheck source=/dev/null
        . "$script"
    fi
    conda activate "$env_name"
    [[ "$nounset" -eq 1 ]] && set -u
    return 0
}

# FIXME Rework the variables as a dictionary here instead.
koopa::conda_create_bioinfo_envs() { # {{{1
    # """
    # Create Conda bioinformatics environments.
    # @note Updated 2021-04-30.
    # """
    local all aligners chipseq data_mining enrichment env envs file_formats \
        methylation quality_control reticulate riboseq rnaseq single_cell \
        trimming variation version workflows
    koopa::assert_is_installed conda
    all=0
    aligners=0
    chipseq=0
    data_mining=0
    enrichment=0
    file_formats=0
    methylation=0
    quality_control=0
    reticulate=0
    riboseq=0
    rnaseq=0
    single_cell=0
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
        reticulate=1
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
            --enrichment)
                enrichment=1
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
            --reticulate)
                reticulate=1
                shift 1
                ;;
            --riboseq|--ribo-seq)
                riboseq=1
                shift 1
                ;;
            --rnaseq|--rna-seq)
                rnaseq=1
                shift 1
                ;;
            --singlecell|--single-cell)
                single_cell=1
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
        enrichment=1
        file_formats=1
        methylation=1
        quality_control=1
        reticulate=1
        riboseq=1
        rnaseq=1
        single_cell=1
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
        envs+=(
            'entrez-direct'
            'sra-tools'
        )
    fi
    if [[ "$enrichment" -eq 1 ]]
    then
        envs+=(
            'meme'  # MEME Suite
        )
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
            'kraken2'
            'multiqc'
            'qualimap'
        )
    fi
    if [[ "$riboseq" -eq 1 ]]
    then
        envs+=(
            'ribocode'
            'ribodiff'
        )
        if koopa::is_linux
        then
            envs+=(
                'ribotaper'
            )
        fi
    fi
    if [[ "$rnaseq" -eq 1 ]]
    then
        # Consider: rapmap
        envs+=('kallisto' 'salmon')
    fi
    if [[ "$reticulate" -eq 1 ]]
    then
        envs+=(
            'numpy'
            'pandas'
            'scikit-learn'
            'umap-learn'
        )
    fi
    if [[ "$single_cell" -eq 1 ]]
    then
        # FIXME Consider adding VeloViz, scClustViz, loomR here too.
        # FIXME Is loomR already available?
        envs+=('r-monocle3')
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
            'miniwdl'
            'nextflow'
            'picard'
            'snakemake'
        )
    fi
    for i in ${!envs[*]}
    do
        env="${envs[$i]}"
        version="$(koopa::variable "conda-${env}")"
        envs[$i]="${env}@${version}"
    done
    koopa::conda_create_env "${envs[@]}"
    return 0
}

koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2021-01-20.
    #
    # Creates a unique environment for each recipe requested.
    # Supports versioning, which will return as 'star@2.7.5a' for example.
    # """
    local conda_prefix force env_name env_string env_version pos prefix
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
    for env_string in "$@"
    do
        # Note that we're using 'salmon@1.4.0' for the environment name but
        # must use 'salmon=1.4.0' in the call to conda below.
        env_string="${env_string//@/=}"
        # If the version isn't specified, fetch the latest one automatically.
        if ! koopa::str_match "$env_string" '='
        then
            env_version="$(koopa::conda_env_latest_version "$env_string")"
            [[ -n "$env_version" ]] || return 1
            env_string="${env_string}=${env_version}"
        fi
        env_name="${env_string//=/@}"
        prefix="${conda_prefix}/envs/${env_name}"
        if [[ -d "$prefix" ]]
        then
            if [[ "$force" -eq 1 ]]
            then
                conda remove --name "$env_name" --all
            else
                koopa::alert_note "Conda environment '${env_name}' exists."
                continue
            fi
        fi
        koopa::alert "Creating '${env_name}' conda environment."
        conda create --name="$env_name" --quiet --yes "$env_string"
        koopa::sys_set_permissions -r "$prefix"
    done
    return 0
}

koopa::conda_env_latest_version() { # {{{1
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2021-01-20.
    # """
    local env_name
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed awk conda
    env_name="${1:?}"
    x="$( \
        conda search "$env_name" \
            | tail -n 1 \
            | awk '{print $2}'
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
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
    # @note Updated 2021-01-19.
    #
    # Attempt to locate by default path first, which is the fastest approach.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa::conda_env_prefix 'deeptools'
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # - conda info --envs
    # - conda info --json
    # """
    local conda_prefix env_dir env_list env_name x
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed conda
    env_name="${1:?}"
    [[ -n "$env_name" ]] || return 1
    env_list="${2:-}"
    if [[ -z "$env_list" ]]
    then
        conda_prefix="$(koopa::conda_prefix)"
        x="${conda_prefix}/envs/${env_name}"
        if [[ -d "$x" ]]
        then
            koopa::print "$x"
            return 0
        fi
        env_list="$(koopa::conda_env_list)"
    fi
    env_list="$(koopa::print "$env_list" | grep "$env_name")"
    [[ -n "$env_list" ]] || return 1
    # Note that this step attempts to automatically match the latest version.
    env_dir="$( \
        koopa::print "$env_list" \
        | grep -E "/${env_name}(@[.0-9]+)?\"" \
        | tail -n 1 \
    )"
    x="$(koopa::print "$env_dir" | sed -E 's/^.*"(.+)".*$/\1/')"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2021-01-19.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # """
    local arg env_prefix nounset
    koopa::assert_has_args "$#"
    koopa::activate_conda
    koopa::assert_is_installed conda
    nounset="$(koopa::boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +u
    for arg in "$@"
    do
        env_prefix="$(koopa::conda_env_prefix "$arg")"
        conda remove --yes --name="$arg" --all
        [[ -d "$env_prefix" ]] && koopa::rm "$env_prefix"
    done
    [[ "$nounset" -eq 1 ]] && set -u
    return 0
}
