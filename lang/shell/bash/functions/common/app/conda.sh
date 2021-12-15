#!/usr/bin/env bash

# FIXME Rework our environment install functions to use 'mamba_or_conda'
# function, which selectively picks mamba over conda.

koopa::activate_conda_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2021-12-15.
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
    local env_name env_prefix nounset
    koopa::assert_has_args_eq "$#" 1
    if koopa::is_conda_env_active
    then
        koopa::stop 'conda environment is already active.'
    fi
    koopa::activate_conda
    nounset="$(koopa::boolean_nounset)"
    env_name="${1:?}"
    env_prefix="$(koopa::conda_env_prefix "$env_name")"
    koopa::assert_is_dir "$env_prefix"
    env_name="$(koopa::basename "$env_prefix")"
    [[ "$nounset" -eq 1 ]] && set +u
    conda activate "$env_name"
    [[ "$nounset" -eq 1 ]] && set -u
    return 0
}

koopa::conda_create_bioinfo_envs() { # {{{1
    # """
    # Create Conda bioinformatics environments.
    # @note Updated 2021-11-18.
    # """
    local dict env envs
    declare -A dict=(
        [name_fancy]='conda environments for bioinformatics'
        [all]=0
        [aligners]=0
        [chipseq]=0
        [data_mining]=0
        [enrichment]=0
        [file_formats]=0
        [methylation]=0
        [quality_control]=0
        [reticulate]=0
        [riboseq]=0
        [rna_modification]=0
        [rnaseq]=0
        [singlecell]=0
        [smallrna]=0
        [spatial]=0
        [trimming]=0
        [variation]=0
        [workflows]=0
    )
    # Set recommended defaults, if necessary.
    if [[ "$#" -eq 0 ]]
    then
        dict[aligners]=1
        dict[chipseq]=1
        dict[data_mining]=1
        dict[file_formats]=1
        dict[reticulate]=1
        dict[rnaseq]=1
        dict[workflows]=1
    fi
    while (("$#"))
    do
        case "$1" in
            '--all')
                dict[all]=1
                shift 1
                ;;
            '--aligners')
                dict[aligners]=1
                shift 1
                ;;
            '--chipseq' | \
            '--chip-seq')
                dict[chipseq]=1
                shift 1
                ;;
            '--data-mining')
                dict[data_mining]=1
                shift 1
                ;;
            '--enrichment')
                dict[enrichment]=1
                shift 1
                ;;
            '--file-formats')
                dict[file_formats]=1
                shift 1
                ;;
            '--methylation')
                dict[methylation]=1
                shift 1
                ;;
            '--qc' | \
            '--quality-control')
                dict[quality_control]=1
                shift 1
                ;;
            '--reticulate')
                dict[reticulate]=1
                shift 1
                ;;
            '--riboseq' | \
            '--ribo-seq')
                dict[riboseq]=1
                shift 1
                ;;
            '--rna-modification')
                dict[rna_modification]=1
                shift 1
                ;;
            '--rnaseq' | \
            '--rna-seq')
                dict[rnaseq]=1
                shift 1
                ;;
            '--singlecell' | \
            '--single-cell')
                dict[singlecell]=1
                shift 1
                ;;
            '--smallrna' | \
            '--small-rna')
                dict[smallrna]=1
                shift 1
                ;;
            '--spatial')
                dict[spatial]=1
                shift 1
                ;;
            '--trimming')
                dict[trimming]=1
                shift 1
                ;;
            '--variation')
                dict[variation]=1
                shift 1
                ;;
            '--workflows')
                dict[workflows]=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::alert_install_start "${dict[name_fancy]}"
    envs=()
    if [[ "${dict[all]}" -eq 1 ]]
    then
        dict[aligners]=1
        dict[chipseq]=1
        dict[data_mining]=1
        dict[enrichment]=1
        dict[file_formats]=1
        dict[methylation]=1
        dict[quality_control]=1
        dict[reticulate]=1
        dict[riboseq]=1
        dict[rna_modification]=1
        dict[rnaseq]=1
        dict[singlecell]=1
        dict[smallrna]=1
        dict[spatial]=1
        dict[trimming]=1
        dict[variation]=1
        dict[workflows]=1
        # Everything else that doesn't have a clear category should go here.
        envs+=(
            'igvtools'
        )
    fi
    if [[ "${dict[aligners]}" -eq 1 ]]
    then
        # Consider:
        # - minimap2
        # - novoalign
        envs+=(
            'bowtie2'
            'bwa'
            'hisat2'
            'rsem'
            'star'
        )
        if koopa::is_linux
        then
            envs+=(
                'bwa-mem2'
            )
        fi
    fi
    if [[ "${dict[chipseq]}" -eq 1 ]]
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
    if [[ "${dict[data_mining]}" -eq 1 ]]
    then
        envs+=(
            'entrez-direct'
            'sra-tools'
        )
    fi
    if [[ "${dict[enrichment]}" -eq 1 ]]
    then
        envs+=(
            'meme'  # MEME Suite
        )
    fi
    if [[ "${dict[file_formats]}" -eq 1 ]]
    then
        # Consider:
        # - ffq (not on conda yet)
        #   https://github.com/pachterlab/ffq
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
            'seqkit'
            'seqtk'
        )
        if koopa::is_linux
        then
            envs+=(
                'biobambam'
            )
        fi
    fi
    if [[ "${dict[methylation]}" -eq 1 ]]
    then
        envs+=(
            'bismark'
        )
    fi
    if [[ "${dict[quality_control]}" -eq 1 ]]
    then
        envs+=(
            'fastqc'
            'kraken2'
            'multiqc'
            'qualimap'
        )
    fi
    if [[ "${dict[riboseq]}" -eq 1 ]]
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
    if [[ "${dict[rna_modification]}" -eq 1 ]]
    then
        envs+=(
            'r-tailfindr'
        )
    fi
    if [[ "${dict[rnaseq]}" -eq 1 ]]
    then
        # Consider:
        # - rapmap
        envs+=(
            'kallisto'
            'salmon'
        )
    fi
    # NOTE Consider renaming this? Useful outside of reticulate...
    if [[ "${dict[reticulate]}" -eq 1 ]]
    then
        envs+=(
            'numpy'
            'pandas'
            'scikit-learn'
            'umap-learn'
        )
    fi
    if [[ "${dict[singlecell]}" -eq 1 ]]
    then
        # Consider:
        # - Rahul Satija Lab
        # - Dana Pe'er Lab
        # - Fabian Theis Lab
        # - Cole Trapnell Lab
        # - Jean Fan Lab
        # - r-harmony
        #   https://github.com/immunogenomics/harmony
        # - harmonypy
        #   https://github.com/slowkow/harmonypy
        # - harmony-pytorch
        #   https://github.com/lilab-bcb/harmony-pytorch
        # - palantir*
        #   https://github.com/dpeerlab/Palantir
        # - r-scclustviz*
        #   https://github.com/BaderLab/scClustViz
        # - r-veloviz*
        #   https://jef.works/veloviz/
        # - scarches
        #   https://github.com/theislab/scarches
        #   Available on PyPi only currently.
        envs+=(
            'bustools'
            'cellrank'
            'r-monocle3'
            'r-seurat'
            'scanpy'
            'scrublet'
        )
    fi
    if [[ "${dict[smallrna]}" -eq 1 ]]
    then
        envs+=(
            # > bioconductor-isomirs
            'mirdeep2'
            'mirtop'
            'seqbuster'
            'seqcluster'
        )
    fi
    if [[ "${dict[spatial]}" -eq 1 ]]
    then
        # Consider:
        # - squidpy*
        envs+=(
            'merfishtools'
        )
    fi
    if [[ "${dict[trimming]}" -eq 1 ]]
    then
        envs+=(
            'atropos'
            'trimmomatic'
        )
    fi
    if [[ "${dict[variation]}" -eq 1 ]]
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
            envs+=(
                'arriba'
            )
        fi
    fi
    if [[ "${dict[workflows]}" -eq 1 ]]
    then
        # Consider:
        # - cromwell
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
    koopa::alert_install_success "${dict[name_fancy]}"
    return 0
}

# FIXME Rework using a dict approach here.
koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2021-10-05.
    #
    # Creates a unique environment for each recipe requested.
    # Supports versioning, which will return as 'star@2.7.5a' for example.
    # """
    local conda conda_prefix force env_name env_string env_version pos prefix
    koopa::assert_has_args "$#"
    force=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--force' | \
            '--reinstall')
                force=1
                shift 1
                ;;
            '-'*)
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
    conda="$(koopa::locate_conda)"
    conda_prefix="$(koopa::conda_prefix)"
    for env_string in "$@"
    do
        # Note that we're using 'salmon@1.4.0' for the environment name but
        # must use 'salmon=1.4.0' in the call to conda below.
        env_string="${env_string//@/=}"
        # If the version isn't specified, fetch the latest one automatically.
        if ! koopa::str_match_fixed "$env_string" '='
        then
            koopa::alert "Obtaining latest version for '${env_string}'."
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
                koopa::conda_remove_env "$env_name"
            else
                koopa::alert_note "Conda environment '${env_name}' \
exists at '${prefix}'."
                continue
            fi
        fi
        koopa::alert_install_start "$env_name" "$prefix"
        "$conda" create \
            --name="$env_name" \
            --quiet \
            --yes \
            "$env_string"
        koopa::sys_set_permissions --recursive "$prefix"
        koopa::alert_install_success "$env_name" "$prefix"
    done
    return 0
}

koopa::conda_env_latest_version() { # {{{1
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2021-11-18.
    # """
    local app dict x
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [conda]="$(koopa::locate_conda)"
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
    )
    # shellcheck disable=SC2016
    x="$( \
        "${app[conda]}" search "${dict[env_name]}" \
            | "${app[tail]}" -n 1 \
            | "${app[awk]}" '{print $2}'
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2021-11-18.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa::locate_conda)"
    )
    x="$("${app[conda]}" env list --json)"
    koopa::print "$x"
    return 0
}

# FIXME Rework this using dict approach.
koopa::conda_env_prefix() { # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2021-10-25.
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
    local app conda_prefix env_dir env_list env_name sed tail x
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
        [tail]="$(koopa::locate_tail)"
    )
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
    env_list="$( \
        koopa::print "$env_list" \
            | koopa::grep "$env_name" \
    )"
    if [[ -z "$env_list" ]]
    then
        koopa::stop "conda environment does not exist: '${env_name}'."
    fi
    # Note that this step attempts to automatically match the latest version.
    env_dir="$( \
        koopa::print "$env_list" \
            | koopa::grep --extended-regexp "/${env_name}(@[.0-9]+)?\"" \
            | "${app[tail]}" -n 1 \
    )"
    x="$( \
        koopa::print "$env_dir" \
            | "${app[sed]}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    if [[ -z "$x" ]]
    then
        koopa::stop "Failed to get path for conda environment: '${env_name}'."
    fi
    koopa::print "$x"
    return 0
}

# FIXME I think the conda environment step here is unnecessary, rework.
koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2021-08-16.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # """
    local name nounset prefix
    koopa::assert_has_args "$#"
    nounset="$(koopa::boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +u
    koopa::activate_conda
    conda="$(koopa::locate_conda)"
    for name in "$@"
    do
        prefix="$(koopa::conda_env_prefix "$name")"
        koopa::assert_is_dir "$prefix"
        name="$(koopa::basename "$prefix")"
        koopa::alert_uninstall_start "$name" "$prefix"
        # Don't set the '--all' flag here, it can break other recipes.
        "$conda" env remove --name="$name" --yes
        [[ -d "$prefix" ]] && koopa::rm "$prefix"
        koopa::alert_uninstall_success "$name" "$prefix"
    done
    [[ "$nounset" -eq 1 ]] && set -u
    return 0
}
