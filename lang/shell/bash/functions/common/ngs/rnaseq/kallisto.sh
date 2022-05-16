#!/usr/bin/env bash

koopa_kallisto_fastq_library_type() {
    # """
    # Convert salmon FASTQ library type to kallisto conventions.
    # @note Updated 2022-03-25.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/
    #     kallisto.py
    #
    # @examples
    # > koopa_kallisto_fastq_library_type 'ISF'
    # # --fr-stranded
    # > koopa_kallisto_fastq_library_type 'ISR'
    # # --rf-stranded
    # """
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'A' | 'IU' | 'U')
            # fr-unstranded.
            return 0
            ;;
        'ISF')
            # fr-secondstrand (ligation).
            to='--fr-stranded'
            ;;
        'ISR')
            # fr-firststrand (dUTP).
            to='--rf-stranded'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}

koopa_kallisto_index() {
    # """
    # Generate kallisto index.
    # @note Updated 2022-03-25.
    #
    # @seealso
    # - kallisto index --help
    #
    # @examples
    # > koopa_kallisto_index \
    # >     --output-dir='salmon-index' \
    # >     --transcriptome-fasta-file='gencode.v39.transcripts.fa.gz'
    # """
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [kallisto]="$(koopa_locate_kallisto)"
    )
    declare -A dict=(
        [kmer_size]=31
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        # e.g. 'kallisto-index'.
        [output_dir]=''
        # e.g. 'gencode.v39.transcripts.fa.gz'.
        [transcriptome_fasta_file]=''
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--output-dir' "${dict[output_dir]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto index requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file "${dict[transcriptome_fasta_file]}"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.fa(sta)?' \
        --string="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    dict[index_file]="${dict[output_dir]}/kallisto.idx"
    koopa_alert "Generating kallisto index at '${dict[output_dir]}'."
    index_args+=(
        "--index=${dict[index_file]}"
        "--kmer-size=${dict[kmer_size]}"
        '--make-unique'
        "${dict[transcriptome_fasta_file]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[kallisto]}" index "${index_args[@]}"
    koopa_alert_success "kallisto index created at '${dict[output_dir]}'."
    return 0
}

koopa_quant_kallisto_paired_end() {
    # """
    # Run kallisto quant on multiple paired-end FASTQs in a directory.
    # @note Updated 2022-03-25.
    #
    # @examples
    # > koopa_kallisto_quant_paired_end \
    # >     --fastq-dir='fastq' \
    # >     --fastq-r1-tail='_R1_001.fastq.gz' \
    # >     --fastq-r2-tail='_R2_001.fastq.gz' \
    # >     --output-dir='kallisto'
    # """
    local dict fastq_r1_files fastq_r1_file fastq_r2_file
    koopa_assert_has_args "$#"
    declare -A dict=(
        # e.g. 'fastq'.
        [fastq_dir]=''
        # e.g. '_R1_001.fastq.gz'.
        [fastq_r1_tail]=''
        # e.g. "_R2_001.fastq.gz'
        [fastq_r2_tail]=''
        # e.g. 'kallisto-index'.
        [index_dir]=''
        # Using salmon fragment library type conventions here.
        [lib_type]='A'
        [mode]='paired-end'
        # e.g. 'kallisto'.
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
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
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
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_r1_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type 'f' \
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
        koopa_kallisto_quant_paired_end_per_sample \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'kallisto quant was successful.'
    return 0
}

koopa_kallisto_quant_paired_end_per_sample() {
    # """
    # Run kallisto quant on a paired-end sample.
    # @note Updated 2022-03-25.
    #
    # Consider adding support for '--genomebam' and '--pseudobam' output,
    # which requires GTF file input ('--gtf') and chromosome names
    # ('--chromosomes'), which can be generated from the GTF file or the
    # genome FASTA file.
    #
    # @section Important options:
    #
    # * --bias: Learns parameters for a model of sequences specific bias and
    #   corrects the abundances accordlingly.
    # * --fr-stranded: Run kallisto in strand specific mode, only fragments
    #   where the first read in the pair pseudoaligns to the forward strand of a
    #   transcript are processed. If a fragment pseudoaligns to multiple
    #   transcripts, only the transcripts that are consistent with the first
    #   read are kept.
    # * --rf-stranded: Same as '--fr-stranded', but the first read maps to the
    #   reverse strand of a transcript.
    #
    # @section Stranded mode:
    #
    # Run kallisto in stranded mode, depending on the library type. Using salmon
    # library type codes here, for consistency. Doesn't currently support an
    # auto detection mode, like salmon. Most current libraries are 'ISR' /
    # '--rf-stranded', if unsure.
    #
    # @seealso
    # - kallisto quant --help
    # - https://pachterlab.github.io/kallisto/manual
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    #
    # @examples
    # > koopa_kallisto_quant_paired_end_per_sample \
    # >     --fastq-r1-file='fastq/sample1_R1_001.fastq.gz' \
    # >     --fastq-r1-tail='_R1_001.fastq.gz' \
    # >     --fastq-r2-file='fastq/sample1_R2_001.fastq.gz' \
    # >     --fastq-r2-tail="_R2_001.fastq.gz' \
    # >     --index-dir='kallisto-index' \
    # >     --output-dir='kallisto'
    # """
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [kallisto]="$(koopa_locate_kallisto)"
    )
    declare -A dict=(
        # Current recommendation in bcbio-nextgen.
        [bootstraps]=30
        # e.g. 'sample1_R1_001.fastq.gz'
        [fastq_r1_file]=''
        # e.g. '_R1_001.fastq.gz'.
        [fastq_r1_tail]=''
        # e.g. 'sample1_R2_001.fastq.gz'.
        [fastq_r2_file]=''
        # e.g. '_R2_001.fastq.gz'.
        [fastq_r2_tail]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        [threads]="$(koopa_cpu_count)"
    )
    quant_args=()
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
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
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
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    koopa_assert_is_file \
        "${dict[fastq_r1_file]}" \
        "${dict[fastq_r2_file]}" \
        "${dict[index_file]}"
    dict[fastq_r1_file]="$(koopa_realpath "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="$(koopa_basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_file]="$(koopa_realpath "${dict[fastq_r2_file]}")"
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
    koopa_alert "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    quant_args+=(
        "--bootstrap-samples=${dict[bootstraps]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[output_dir]}"
        "--threads=${dict[threads]}"
        '--bias'
        '--verbose'
    )
    dict[lib_type]="$(koopa_kallisto_fastq_library_type "${dict[lib_type]}")"
    if [[ -n "${dict[lib_type]}" ]]
    then
        quant_args+=("${dict[lib_type]}")
    fi
    quant_args+=("${dict[fastq_r1_file]}" "${dict[fastq_r2_file]}")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[kallisto]}" quant "${quant_args[@]}"
    return 0
}

koopa_kallisto_quant_single_end() {
    # """
    # Run kallisto on multiple single-end FASTQ files.
    # @note Updated 2022-03-25.
    #
    # @examples
    # > koopa_kallisto_quant_single_end \
    # >     --fastq-dir='fastq' \
    # >     --fastq-tail='_001.fastq.gz' \
    # >     --output-dir='kallisto'
    # """
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        # e.g. 'fastq'
        [fastq_dir]=''
        # e.g. "_001.fastq.gz'.
        [fastq_tail]=''
        # e.g. 'kallisto-index'.
        [index_dir]=''
        [mode]='single-end'
        # e.g. 'kallisto'.
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
                dict[fastq-tail]="${2:?}"
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
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
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
        koopa_kallisto_quant_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'kallisto quant was successful.'
    return 0
}

koopa_kallisto_quant_single_end_per_sample() {
    # """
    # Run kallisto quant (per single-end sample).
    # @note Updated 2022-03-25.
    #
    # Consider adding support for '--genomebam' and '--pseudobam' output,
    # which requires GTF file input ('--gtf') and chromosome names
    # ('--chromosomes'), which can be generated from the GTF file or the
    # genome FASTA file.
    #
    # @section Fragment length:
    #
    # Must supply the length and standard deviation of the fragment length
    # (not the read length).
    #
    # Fragment length refers to the length of the fragments loaded onto the
    # sequencer. If this is your own dataset, then either you or whoever did the
    # sequencing should know this (it can be estimated from a bioanalyzer plot).
    # If this is a public dataset, then hopefully the value is written down
    # somewhere.
    #
    # @seealso
    # - https://www.biostars.org/p/252823/
    #
    # @examples
    # > koopa_kallisto_quant_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --fastq-tail='_001.fastq.gz' \
    # >     --index-dir='kallisto-index' \
    # >     --output-dir='kallisto'
    # """
    local app dict quant_args
    declare -A app=(
        [kallisto]="$(koopa_locate_kallisto)"
    )
    declare -A dict=(
        # Current recommendation in bcbio-nextgen.
        [bootstraps]=30
        # e.g. 'sample1_001.fastq.gz'.
        [fastq_file]=''
        # e.g. '_001.fastq.gz'.
        [fastq_tail]=''
        # Current recommendation in bcbio-nextgen.
        [fragment_length]=200
        # e.g. 'kallisto-index'.
        [index_dir]=''
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        # e.g. 'kallisto'.
        [output_dir]=''
        # Current recommendation in bcbio-nextgen.
        [sd]=25
    )
    quant_args=()
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
            '--fragment-length='*)
                dict[fragment_length]="${1#*=}"
                shift 1
                ;;
            '--fragment-length')
                dict[fragment_length]="${2:?}"
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
        '--fragment-length' "${dict[fragment_length]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--output-dir' "${dict[output_dir]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto quant requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_dir "${dict[index_dir]}"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    koopa_assert_is_file "${dict[fastq_file]}" "${dict[index_file]}"
    dict[fastq_file]="$(koopa_realpath "${dict[fastq_file]}")"
    dict[fastq_bn]="$(koopa_basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[fastq_tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_alert "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    quant_args+=(
        "--bootstrap-samples=${dict[bootstraps]}"
        "--fragment-length=${dict[fragment_length]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[output_dir]}"
        "--sd=${dict[sd]}"
        '--single'
        "--threads=${dict[threads]}"
        '--verbose'
    )
    quant_args+=("$fastq_file")
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app[kallisto]}" quant "${quant_args[@]}"
    return 0
}

