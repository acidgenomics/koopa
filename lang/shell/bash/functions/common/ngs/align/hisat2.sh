#!/usr/bin/env bash

koopa_hisat2_align_paired_end() { # {{{1
    # """
    # Run HISAT2 aligner on multiple paired-end FASTQs in a directory.
    # @note Updated 2022-03-24.
    # """
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [index_dir]=''
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running HISAT2 aligner (paired-end mode).'
    koopa_dl \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'Index dir' "${dict[index_dir]}" \
        'Mode' 'paired-end' \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_r1_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa_hisat2_align_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}

koopa_hisat2_align_paired_end_per_sample() { # {{{1
    # """
    # Run HISAT2 aligner on a paired-end sample.
    # @note Updated 2022-03-24.
    #
    # @seealso
    # - hisat2 --help
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/ngsalign/
    #     hisat2.py
    # - https://daehwankimlab.github.io/hisat2/manual/
    # """
    local align_args app dict
    declare -A app=(
        [hisat2]="$(koopa_locate_hisat2)"
    )
    declare -A dict=(
        [fastq_r1_file]=''
        [fastq_r1_tail]='' # '_R1_001.fastq.gz'
        [fastq_r2_file]=''
        [fastq_r2_tail]='' # '_R2_001.fastq.gz'
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [quality_format]='phred33'
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    koopa_assert_is_file "${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_bn]="$(koopa_basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa_assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."


    dict[hisat2_idx]="${dict[index_dir]}/index"
    dict[sam_file]="${dict[output_dir]}/${dict[id]}.sam"

    dict[quality_format_r1]="$( \
        koopa_fastq_detect_quality_format "${dict[fastq_r1_file]}" \
    )"
    dict[quality_format_r2]="$( \
        koopa_fastq_detect_quality_format "${dict[fastq_r2_file]}" \
    )"
    koopa_assert_are_identical \
        "${dict[quality_format_r1]}" \
        "${dict[quality_format_r2]}"
    case "${dict[quality_format_r1]}" in
        'phread33')
            dict[quality_flag]='--phred33'
            ;;
        'phread64')
            dict[quality_flag]='--phred64'
            ;;
        *)
            koopa_stop 'Unsupported quality format.'
            ;;
    esac

    # FIXME Need to handle strandedness here.
    # FIXME What is '--new-summary' flag?
    # FIXME Check if FASTQ is phread64, otherwise assume phred33 by default.

    # FIXME Need to support this:
    # --rna-strandness <string>          specify strand-specific information (unstranded)


# FIXME Need to add lib-type here, defaulting to 'A'
# FIXME Need to add support for unstranded.
# FIXME Set '--rna-strandedness from this.

    align_args+=(
        '--new-summary'
        "${dict[quality_flag]}"
        '--threads' "${dict[threads]}"
        '-1' "${dict[fastq_r1_file]}"
        '-2' "${dict[fastq_r2_file]}"
        '-S' "${dict[sam_file]}"
        '-q'
        '-x' "${dict[hisat2_idx]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}"
    return 0
}

koopa_hisat2_align_single_end() { # {{{1
    # """
    # Run HISAT2 aligner on multiple single-end FASTQs in a directory.
    # @note Updated 2022-03-24.
    # """
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [fastq_dir]=''
        [fastq_tail]='' # '.fastq.gz'
        [index_dir]=''
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running HISAT2 aligner (single-end mode).'
    koopa_dl \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Index dir' "${dict[index_dir]}" \
        'Mode' 'single-end' \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_hisat2_align_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}



# FIXME Strandedness is not common for single end sequencing.
# FIXME Need to add lib-type here, defaulting to 'A'
# FIXME Need to add support for unstranded.
# FIXME Set '--rna-strandedness from this.

# FIXME Can we pass in gzipped files or we do we need to decompress?
koopa_hisat2_align_single_end_per_sample() { # {{{1
    # """
    # Run HISAT2 aligner on a single-end sample.
    # @note Updated 2022-03-24.
    # """
    local align_args app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [hisat2]="$(koopa_locate_hisat2)"
    )
    declare -A dict=(
        [fastq_file]=''
        [fastq_tail]='' # '.fastq.gz'
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
    )
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' in '${dict[output_dir]}'."

    dict[hisat2_idx]="${dict[index_dir]}/index"
    dict[sam_file]="${dict[output_dir]}/${dict[id]}.sam"

    align_args+=(
        '-S' "${dict[sam_file]}"
        '-U' "${dict[fastq_file]}"
        '-q'
        '-x' "${dict[hisat2_idx]}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app[star]}" "${align_args[@]}"
    return 0
}

# HISAT2 includes 'hisat2_extract_exons.py' that does this.
# HISAT2 includes 'hisat2_extract_splice_sites.py' which does this.

koopa_hisat2_index() { # {{{1
    # """
    # Create a genome index for HISAT2 aligner.
    # @note Updated 2022-03-24.
    #
    # Doesn't currently support compressed files as input.
    #
    # Try using 'r5a.2xlarge' on AWS EC2.
    #
    # If you use '--snp', '--ss', and/or '--exon', hisat2-build will need about
    # 200 GB RAM for the human genome size as index building involves a graph
    # construction. Otherwise, you will be able to build an index on your
    # desktop with 8 GB RAM.
    #
    # @seealso
    # - hisat2-build --help
    # - https://daehwankimlab.github.io/hisat2/manual/
    # - https://daehwankimlab.github.io/hisat2/download/#h-sapiens
    # - https://www.biostars.org/p/286647/
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/
    #     modules/hisat2/build/main.nf
    # - https://github.com/chapmanb/cloudbiolinux/blob/master/utils/
    #     prepare_tx_gff.py
    # """
    local app dict index_args
    declare -A app=(
        [hisat2_build]="$(koopa_locate_hisat2_build)"
    )
    declare -A dict=(
        # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
        [genome_fasta_file]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=200
        [output_dir]=''
        [seed]=42
        [threads]="$(koopa_cpu_count)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-dir' "${dict[output_dir]}"
    dict[ht2_base]="${dict[output_dir]}/index"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "'hisat2-build' requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file "${dict[genome_fasta_file]}"
    koopa_assert_is_matching_regex \
        --pattern='\.fa\.gz$' \
        --string="${dict[genome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    koopa_alert "Generating HISAT2 index at '${dict[output_dir]}'."
    index_args+=(
        # FIXME Need to set '--ss' here.
        # FIXME Need to set '--exons' here.
        '--seed' "${dict[seed]}"
        '-f'
        '-p' "${dict[threads]}"
        "${dict[genome_fasta_file]}"
        "${dict[ht2_base]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[hisat2_build]}" "${index_args[@]}"
    koopa_alert_success "HISAT2 index created at '${dict[output_dir]}'."
    return 0
}

koopa_hisat2_library_strandedness() { # {{{1
    # """
    # Convert salmon library type to HISAT2 strandedness.
    # @note Updated 2022-03-24.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://rnabio.org/module-09-appendix/0009/12/01/StrandSettings/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     ngsalign/hisat2.py
    # """
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'ISF')
            # fr-secondstrand (ligation).
            to='FR'
            ;;
        'ISR')
            # fr-firststrand (dUTP).
            to='RF'
            ;;
        'SF')
            # fr-secondstrand.
            to='F'
            ;;
        'SR')
            # fr-firststrand.
            to='R'
            ;;
        *)
            # -fr-unstranded; samon IU, U.
            return 1
            ;;
    esac
    koopa_print "$to"
    return 0
}
