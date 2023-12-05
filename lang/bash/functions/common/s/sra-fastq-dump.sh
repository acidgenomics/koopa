#!/usr/bin/env bash

# NOTE Consider looking into aria2c or axel approach to speed this up.
#
# http://genomespot.blogspot.com/2015/01/sra-toolkit-tips-and-workarounds.html
# https://www.biostars.org/p/450078/
#
# axel -n5 ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/sra/SRX/SRX709/SRX709649/SRR1585277/SRR1585277.sra
#
# After downloading, can call fastq-dump on the local files.
#
# Canonical URL is:
# ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR504/SRR504687/SRR504687.sra
#
# ENA often contains the FASTQs already split out too, which is nice:
# ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR504/SRR504687/SRR504687_1.fastq.gz
# ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR504/SRR504687/SRR504687_2.fastq.gz

koopa_sra_fastq_dump() {
    # """
    # Dump FASTQ files from SRA file list.
    # @note Updated 2023-11-10.
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
    # - https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump
    # - https://github.com/ncbi/sra-tools/wiki/08.-prefetch-and-fasterq-dump
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
    # e.g. 'fastq'.
    dict['fastq_dir']=''
    # e.g. 'sra'.
    dict['prefetch_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
        '--fastq-directory' "${dict['fastq_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    koopa_assert_is_ncbi_sra_toolkit_configured
    koopa_assert_is_dir "${dict['prefetch_dir']}"
    dict['prefetch_dir']="$(koopa_realpath "${dict['prefetch_dir']}")"
    dict['fastq_dir']="$(koopa_init_dir "${dict['fastq_dir']}")"
    koopa_alert "Dumping FASTQ files from '${dict['prefetch_dir']}' \
in '${dict['fastq_dir']}'."
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
        local -A dict2
        dict2['sra_file']="$sra_file"
        dict2['id']="$(koopa_basename_sans_ext "${dict2['sra_file']}")"
        if [[ -f "${dict['fastq_dir']}/${dict2['id']}.fastq" ]] || \
            [[ -f "${dict['fastq_dir']}/${dict['id']}_1.fastq" ]] || \
            [[ -f "${dict['fastq_dir']}/${dict2['id']}.fastq.gz" ]] || \
            [[ -f "${dict['fastq_dir']}/${dict2['id']}_1.fastq.gz" ]]
        then
            koopa_alert_info "Skipping '${dict2['sra_file']}'."
            continue
        fi
        koopa_alert "Dumping '${dict2['sra_file']}' FASTQ \
into '${dict['fastq_dir']}'."
        "${app['fasterq_dump']}" \
            --details \
            --force \
            --outdir "${dict['fastq_dir']}" \
            --progress \
            --skip-technical \
            --split-3 \
            --threads "${dict['threads']}" \
            --verbose \
            "${dict2['sra_file']}"
        if [[ "${bool['compress']}" -eq 1 ]]
        then
            koopa_alert "Compressing '${dict['id']}' FASTQ \
in '${dict['fastq_dir']}'."
            readarray -t fastq_files <<< "$( \
                koopa_find \
                    --max-depth=1 \
                    --min-depth=1 \
                    --pattern="${dict2['id']}*.fastq" \
                    --prefix="${dict['fastq_dir']}" \
                    --sort \
                    --type='f' \
            )"
            koopa_assert_is_array_non_empty "${fastq_files[@]:-}"
            koopa_compress --format='gzip' --remove "${fastq_files[@]}"
            koopa_assert_is_not_file "${fastq_files[@]}"
        fi
    done
    return 0
}
