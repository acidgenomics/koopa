#!/usr/bin/env bash

koopa_sra_fastq_dump() {
    # """
    # Dump FASTQ files from SRA file list.
    # @note Updated 2023-11-07.
    #
    # @section fasterq-dump vs. fastq-dump:
    #
    # 1. In fastq-dump, the flag '--split-3' is required to separate paired
    #    reads into left and right ends. This is the default setting in
    #    fasterq-dump.
    # 2. The fastq-dump flag '--skip-technical' is no longer required to skip
    #    technical reads in fasterq-dump. Instead, the flag
    #    '--include-technical' is required to include technical reads when
    #    using fasterq-dump.
    # 3. There is no '--gzip' or '--bzip2' flag in fasterq-dump to download
    #    compressed reads with fasterq-dump.
    #
    # fastq-dump-specific arguments:
    # * '--clip': Remove adapter sequences from reads.
    # * '--dumpbase': Formats sequence using base space
    #   (default for other than SOLiD).
    # * '--readids': Append read id after spot id as 'accession.spot.readid'
    #   on defline.
    # * '--read-filter <filter>': Split into files by 'READ_FILTER' value.
    #   [split], optionally filter by value:
    #   [pass|reject|criteria|redacted]
    #
    # fasterq-dump-specific arguments:
    # * '--details': Print details of all options selected.
    # * '--force': Force overwrite of existing files.
    # * '--print-read-nr': Include read-number in defline.
    # * '--progress': Show progress (not possible if stdout used).
    # * '--strict': Terminate on invalid read.
    # * '--temp <path>': Path to directory for temporary files.
    # * '--threads <count>': Number of threads to use.
    # * '--verbose': Increase the verbosity of the program status messages.
    #    Use multiple times for more verbosity.
    #
    # Arguments supported by both fastq-dump and fasterq-dump:
    # * '--split-3': Use this instead of '--split-files'. 3-way splitting for
    #   mate-pairs. For each spot, if there are two biological reads satisfying
    #   filter conditions, the first is placed in the '*_1.fastq' file, and the
    #   second is placed in the '*_2.fastq' file. If there is only one
    #   biological read satisfying the filter conditions, it is placed in the
    #   '*.fastq' file. All other reads in the spot are ignored.
    #
    # @seealso
    # - https://rnnh.github.io/bioinfo-notebook/docs/fasterq-dump.html
    # - https://edwards.sdsu.edu/research/the-perils-of-fasterq-dump/
    # - https://www.reneshbedre.com/blog/ncbi_sra_toolkit.html
    #
    # @examples
    # > koopa_sra_fastq_dump \
    # >     --accession-file='srp049596-accession-list.txt' \
    # >     --prefetch-directory='srp049596-prefetch' \
    # >     --fastq-directory='srp049596-fastq'
    # """
    local -A app bool dict
    local -a fastq_files sra_files
    local sra_file
    app['fasterq_dump']="$(koopa_locate_fasterq_dump)"
    koopa_assert_is_executable "${app[@]}"
    bool['compress']=1
    dict['acc_file']=''
    dict['fastq_dir']='fastq'
    dict['prefetch_dir']='sra'
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--accession-file='*)
                dict['acc_file']="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict['acc_file']="${2:?}"
                shift 2
                ;;
            '--fastq-directory='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-directory')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict['prefetch_dir']="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict['prefetch_dir']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--compress')
                bool['compress']=1
                shift 1
                ;;
            '--no-compress')
                bool['compress']=0
                shift 1
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--accession-file' "${dict['acc_file']}" \
        '--fastq-directory' "${dict['fastq_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    koopa_assert_is_file "${dict['acc_file']}"
    koopa_assert_is_ncbi_sra_toolkit_configured
    if [[ ! -d "${dict['prefetch_dir']}" ]]
    then
        koopa_sra_prefetch \
            --accession-file="${acc_file}" \
            --output-directory="${dict['prefetch_dir']}"
    fi
    koopa_assert_is_dir "${dict['prefetch_dir']}"
    koopa_alert "Extracting FASTQ to '${dict['fastq_dir']}'."
    readarray -t sra_files <<< "$(
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict['prefetch_dir']}" \
            --sort \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local id
        id="$(koopa_basename_sans_ext "$sra_file")"
        if [[ -f "${dict['fastq_dir']}/${id}.fastq" ]] || \
            [[ -f "${dict['fastq_dir']}/${id}_1.fastq" ]] || \
            [[ -f "${dict['fastq_dir']}/${id}.fastq.gz" ]] || \
            [[ -f "${dict['fastq_dir']}/${id}_1.fastq.gz" ]]
        then
            koopa_alert_info "Skipping '${sra_file}'."
            continue
        fi
        koopa_alert "Extracting FASTQ in '${sra_file}'."
        "${app['fasterq_dump']}" \
            --details \
            --force \
            --outdir "${dict['fastq_dir']}" \
            --print-read-nr \
            --progress \
            --skip-technical \
            --split-3 \
            --strict \
            --threads "${dict['threads']}" \
            --verbose \
            "$sra_file"
    done
    if [[ "${bool['compress']}" -eq 1 ]]
    then
        koopa_alert "Compressing FASTQ files in '${dict['fastq_dir']}'."
        readarray -t fastq_files <<< "$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --pattern='*.fastq' \
                --prefix="${dict['fastq_dir']}" \
                --sort \
                --type='f' \
        )"
        koopa_compress "${fastq_files[@]}"
    fi
    return 0
}
