#!/usr/bin/env bash
# shellcheck disable=SC2039

koopa::conda_create_bioinfo_envs() {
    # """
    # Create Conda bioinformatics environments.
    # @note Updated 2020-07-14.
    # """
    local all aligners chipseq data_mining envs file_formats methylation \
        quality_control rnaseq trimming variation workflows
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
    fi
    koopa::h1 'Installing conda environments for bioinformatics.'
    envs=()
    if [[ "$file_formats" -eq 1 ]]
    then
        koopa::h2 'File formats'
        envs+=(
            "bamtools=2.5.1"
            "bcftools=1.10.2"
            "bedtools=2.29.2"
            "bioawk=1.0"
            "gffutils=0.10.1"
            "htslib=1.10.2"
            "sambamba=0.7.1"
            "samblaster=0.1.26"
            "samtools=1.10"
            "seqtk=1.3"
        )
        if koopa::is_linux
        then
            envs+=("biobambam=2.0.87")
        fi
    fi
    if [[ "$data_mining" -eq 1 ]]
    then
        koopa::h2 'Data mining'
        envs+=(
            "entrez-direct=13.3"
            "sra-tools=2.10.1"
        )
    fi
    if [[ "$workflows" -eq 1 ]]
    then
        koopa::h2 'Workflows'
        # Consider: cromwell
        envs+=(
            "fgbio=1.2.0"
            "gat4k=4.1.8.0"
            "jupyterlab=2.1.5"
            "nextflow=20.04.1"
            "picard=2.23.2"
            "snakemake=5.20.1"
        )
    fi
    if [[ "$quality_control" -eq 1 ]]
    then
        koopa::h2 'Quality control'
        envs+=(
            "fastqc=0.11.9"
            "kraken=1.1.1"
            "multiqc=1.9"
            "qualimap=2.2.2d"
        )
    fi
    if [[ "$trimming" -eq 1 ]]
    then
        koopa::h2 'Trimming'
        envs+=(
            "atropos=1.1.28"
            "trimmomatic=0.39"
        )
    fi
    if [[ "$aligners" -eq 1 ]]
    then
        koopa::h2 'Aligners'
        # Consider: minimap2, novoalign
        envs+=(
            "bowtie2=2.4.1"
            "bwa=0.7.17"
            "hisat2=2.2.0"
            "rsem=1.3.3"
            "star=2.7.5a"
        )
        if koopa::is_linux
        then
            envs+=("bwa-mem2=2.0")
        fi
    fi
    if [[ "$variation" -eq 1 ]]
    then
        koopa::h2 'Variation'
        envs+=(
            "ericscript=0.5.5"
            "oncofuse=1.1.1"
            "peddy=0.4.7"
            "pizzly=0.37.3"
            "squid=1.5"
            "star-fusion=1.9.0"
            "vardict=2019.06.04"
        )
        if koopa::is_linux
        then
            envs+=("arriba=1.2.0")
        fi
    fi
    if [[ "$rnaseq" -eq 1 ]]
    then
        koopa::h2 'RNA-seq'
        # Consider: rapmap
        envs+=(
            "kallisto=0.46.2"
            "salmon=1.3.0"
        )
    fi
    if [[ "$chipseq" -eq 1 ]]
    then
        koopa::h2 'ChIP-seq'
        envs+=(
            "chromhmm=1.21"
            "deeptools=3.4.3"
            "genrich=0.6"
            "homer=4.11"
            "macs2=2.2.7.1"
            "sicer2=1.0.2"
        )
    fi
    if [[ "$methylation" -eq 1 ]]
    then
        koopa::h2 'Methylation'
        envs+=("bismark=0.22.3")
    fi
    if [[ "$all" -eq 1 ]]
    then
        koopa::h2 'Other tools'
        envs+=("igvtools=2.5.3")
    fi
    koopa::conda_create_env "${envs[@]}"
    koopa::sys_set_permissions -r "$(koopa::conda_prefix)"
    conda env list
    return 0
}

koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2020-07-14.
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
        if ! koopa::str_match "$env" '='
        then
            koopa::stop 'Version is required. Specify as "NAME=VERSION".'
        fi
        env_name="${env//=/@}"
        prefix="${conda_prefix}/envs/${env_name}"
        if [[ -d "$prefix" ]]
        then
            if [[ "$force" -eq 1 ]]
            then
                conda remove --name "$env_name" --all
            else
                koopa::note "Conda environment \"${env_name}\" exists."
                continue
            fi
        fi
        koopa::info "Creating \"${env_name}\" conda environment."
        conda create --name="$env_name" --quiet --yes "$env"
        koopa::sys_set_permissions -r "$prefix"
    done
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
