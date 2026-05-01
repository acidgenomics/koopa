#!/usr/bin/env bash

# FIXME Add support for pushing to S3 as a tarball.
# FIXME Capture console output to log file.

_koopa_kallisto_index() {
    # """
    # Generate kallisto index.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - kallisto index --help
    #
    # @examples
    # > _koopa_kallisto_index \
    # >     --output-dir='kallisto-gencode' \
    # >     --transcriptome-fasta-file='gencode.v44.transcripts_fixed.fa.gz'
    # """
    local -A app dict
    local -a index_args
    _koopa_assert_has_args "$#"
    app['kallisto']="$(_koopa_locate_kallisto)"
    _koopa_assert_is_executable "${app[@]}"
    dict['fasta_pattern']="$(_koopa_fasta_pattern)"
    dict['kmer_size']=31
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    # e.g. 'kallisto-gencode'.
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
    # e.g. 'gencode.v44.transcripts_fixed.fa.gz'.
    dict['transcriptome_fasta_file']=''
    dict['version']="$(_koopa_app_version 'kallisto')"
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "kallisto index requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    _koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        _koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    _koopa_assert_is_matching_regex \
        --pattern="${dict['fasta_pattern']}" \
        --string="${dict['transcriptome_fasta_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    dict['index_file']="${dict['output_dir']}/kallisto.idx"
    _koopa_alert "Generating kallisto index at '${dict['output_dir']}'."
    index_args+=(
        "--index=${dict['index_file']}"
        "--kmer-size=${dict['kmer_size']}"
        '--make-unique'
    )
    case "${dict['version']}" in
        '0.50.'*)
            index_args+=("--threads=${dict['threads']}")
            ;;
    esac
    index_args+=("${dict['transcriptome_fasta_file']}")
    _koopa_dl 'Index args' "${index_args[*]}"
    "${app['kallisto']}" index "${index_args[@]}"
    _koopa_alert_success "kallisto index created at '${dict['output_dir']}'."
    return 0
}
