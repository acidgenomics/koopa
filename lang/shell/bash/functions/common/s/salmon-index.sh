#!/usr/bin/env bash

koopa_salmon_index() {
    # """
    # Generate salmon index.
    # @note Updated 2022-03-25.
    #
    # @section GENCODE:
    #
    # Need to pass '--gencode' flag here for GENCODE reference genome.
    # Function attempts to detect this automatically from the file name.
    #
    # @seealso
    # - salmon index --help
    # - https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # - https://www.biostars.org/p/456231/
    # - https://github.com/refgenie/refgenieserver/issues/63
    #
    # @examples
    # # Decoy-aware transcriptome (recommended):
    # > koopa_salmon_index \
    # >     --genome-fasta-file='GRCh38.primary_assembly.genome.fa.gz' \
    # >     --output-dir='salmon-index' \
    # >     --transcriptome-fasta-file='gencode.v39.transcripts.fa.gz'
    #
    # # Decoy-unaware transcriptome (not recommended, but faster and smaller):
    # > koopa_salmon_index \
    # >     --no-decoys \
    # >     --output-dir='salmon-index' \
    # >     --transcriptome-fasta-file='gencode.v39.transcripts.fa.gz'
    # """
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa_locate_salmon)"
    )
    declare -A dict=(
        [decoys]=1
        [gencode]=0
        # e.g. 'GRCh38.primary_assembly.genome.fa.gz'.
        [genome_fasta_file]=''
        [kmer_length]=31
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        # e.g. 'salmon-index'.
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
        # e.g. 'gencode.v39.transcripts.fa.gz'.
        [transcriptome_fasta_file]=''
        [type]='puff'
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
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--decoys')
                dict[decoys]=1
                shift 1
                ;;
            '--gencode')
                dict[gencode]=1
                shift 1
                ;;
            '--no-decoys')
                dict[decoys]=0
                shift 1
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
        koopa_stop "salmon index requires ${dict[mem_gb_cutoff]} GB of RAM."
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
    koopa_alert "Generating salmon index at '${dict[output_dir]}'."
    if [[ "${dict[gencode]}" -eq 0 ]] && \
        koopa_str_detect_regex \
            --string="$(koopa_basename "${dict[transcriptome_fasta_file]}")" \
            --pattern='^gencode\.'
    then
        dict[gencode]=1
    fi
    if [[ "${dict[gencode]}" -eq 1 ]]
    then
        koopa_alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    if [[ "${dict[decoys]}" -eq 1 ]]
    then
        koopa_alert 'Preparing decoy-aware reference transcriptome.'
        koopa_assert_is_set \
            '--genome-fasta-file' "${dict[genome_fasta_file]}"
        koopa_assert_is_file "${dict[genome_fasta_file]}"
        dict[genome_fasta_file]="$(koopa_realpath "${dict[genome_fasta_file]}")"
        koopa_assert_is_matching_regex \
            --pattern='\.fa(sta)?\.gz$' \
            --string="${dict[genome_fasta_file]}"
        koopa_assert_is_matching_regex \
            --pattern='\.fa(sta)?\.gz$' \
            --string="${dict[transcriptome_fasta_file]}"
        dict[tmp_dir]="$(koopa_tmp_dir)"
        dict[decoys_file]="${dict[tmp_dir]}/decoys.txt"
        dict[gentrome_fasta_file]="${dict[tmp_dir]}/gentrome.fa.gz"
        koopa_fasta_generate_chromosomes_file \
            --genome-fasta-file="${dict[genome_fasta_file]}" \
            --output-file="${dict[decoys_file]}"
        koopa_assert_is_file "${dict[decoys_file]}"
        koopa_fasta_generate_decoy_transcriptome_file \
            --genome-fasta-file="${dict[genome_fasta_file]}" \
            --output-file="${dict[gentrome_fasta_file]}" \
            --transcriptome-fasta-file="${dict[transcriptome_fasta_file]}"
        koopa_assert_is_file "${dict[gentrome_fasta_file]}"
        index_args+=(
            "--decoys=${dict[decoys_file]}"
            "--transcripts=${dict[gentrome_fasta_file]}"
        )
    else
        index_args+=(
            "--transcripts=${dict[transcriptome_fasta_file]}"
        )
    fi
    index_args+=(
        "--index=${dict[output_dir]}"
        "--kmerLen=${dict[kmer_length]}"
        '--no-version-check'
        "--threads=${dict[threads]}"
        "--type=${dict[type]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[salmon]}" index "${index_args[@]}"
    koopa_alert_success "salmon index created at '${dict[output_dir]}'."
    return 0
}
