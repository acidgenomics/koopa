#!/usr/bin/env bash

koopa::sra_download_accession_list() { # {{{1
    # """
    # Download SRA accession list.
    # @note Updated 2022-02-11.
    #
    # @examples
    # > koopa::sra_download_accession_list --srp-id='SRP049596'
    # # Downloads 'srp049596-accession-list.txt' to disk.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [efetch]="$(koopa::locate_efetch)"
        [esearch]="$(koopa::locate_esearch)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [acc_file]=''
        [srp_id]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[acc_file]+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict[acc_file]+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict[srp_id]="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict[srp_id]="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[acc_file]}" ]]
    then
        dict[acc_file]="$(koopa::lowercase "${dict[srp_id]}")-\
accession-list.txt"
    fi
    koopa::alert "Downloading SRA accession list for '${dict[srp_id]}' \
to '${dict[acc_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        | "${app[sed]}" '1d' \
        | "${app[cut]}" --delimiter=',' --fields='1' \
        > "${dict[acc_file]}"
    return 0
}

koopa::sra_download_run_info_table() { # {{{1
    # """
    # Download SRA run info table.
    # @note Updated 2022-02-11.
    #
    # @examples
    # > koopa::sra_download_run_info_table --srp-id='SRP049596'
    # # Downloads 'srp049596-run-info-table.csv' to disk.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [efetch]="$(koopa::locate_efetch)"
        [esearch]="$(koopa::locate_esearch)"
    )
    declare -A dict=(
        [run_info_file]=''
        [srp_id]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[run_info_file]+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict[run_info_file]+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict[srp_id]="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict[srp_id]="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[run_info_file]}" ]]
    then
        dict[run_info_file]="$(koopa::lowercase "${dict[srp_id]}")-\
run-info-table.csv"
    fi
    koopa::alert "Downloading SRA run info table for '${dict[srp_id]}' \
to '${dict[run_info_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        > "${dict[run_info_file]}"
    return 0
}

koopa::sra_fastq_dump() { # {{{1
    # """
    # Dump FASTQ files from SRA file list (in parallel).
    # @note Updated 2022-02-10.
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
    # > koopa::sra_fastq_dump \
    # >     --accession-file='srp049596-accession-list.txt' \
    # >     --prefetch-directory='srp049596-prefetch' \
    # >     --fastq-directory='srp049596-fastq'
    # """
    local app dict sra_file sra_files
    declare -A app=(
        [fasterq_dump]="$(koopa::locate_fasterq_dump)"
        [gzip]="$(koopa::locate_gzip)"
        [parallel]="$(koopa::locate_parallel)"
    )
    declare -A dict=(
        [acc_file]=''
        [compress]=1
        [fastq_dir]='fastq'
        [prefetch_dir]='sra'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--accession-file='*)
                dict[acc_file]="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict[acc_file]="${2:?}"
                shift 2
                ;;
            '--fastq-directory='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-directory')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict[prefetch_dir]="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict[prefetch_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--compress')
                dict[compress]=1
                shift 1
                ;;
            '--no-compress')
                dict[compress]=0
                shift 1
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set \
        '--accession-file' "${dict[acc_file]}" \
        '--fastq-directory' "${dict[fastq_dir]}" \
        '--prefetch-directory' "${dict[prefetch_dir]}"
    koopa::assert_is_file "${dict[acc_file]}"
    if [[ ! -d "${dict[prefetch_dir]}" ]]
    then
        koopa::sra_prefetch_parallel \
            --accession-file="${acc_file}" \
            --output-directory="${dict[prefetch_dir]}"
    fi
    koopa::assert_is_dir "${dict[prefetch_dir]}"
    koopa::alert "Extracting FASTQ to '${dict[fastq_dir]}'."
    readarray -t sra_files <<< "$(
        koopa::find \
            --glob='*.sra' \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefetch_dir]}" \
            --sort \
            --type='f' \
    )"
    koopa::assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local id
        id="$(koopa::basename_sans_ext "$sra_file")"
        if [[ ! -f "${dict[fastq_dir]}/${id}.fastq" ]] && \
            [[ ! -f "${dict[fastq_dir]}/${id}_1.fastq" ]] && \
            [[ ! -f "${dict[fastq_dir]}/${id}.fastq.gz" ]] && \
            [[ ! -f "${dict[fastq_dir]}/${id}_1.fastq.gz" ]]
        then
            koopa::alert "Extracting FASTQ in '${sra_file}'."
            "${app[fasterq_dump]}" \
                --details \
                --force \
                --outdir "${dict[fastq_dir]}" \
                --print-read-nr \
                --progress \
                --skip-technical \
                --split-3 \
                --strict \
                --threads "${dict[threads]}" \
                --verbose \
                "$sra_file"
        fi
    done
    if [[ "${dict[compress]}" -eq 1 ]]
    then
        koopa::alert 'Compressing FASTQ files.'
        koopa::find \
            --glob='*.fastq' \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
        | "${app[parallel]}" \
            --bar \
            --eta \
            --jobs "${dict[threads]}" \
            --progress \
            --will-cite \
            "${app[gzip]} --force --verbose {}"
    fi
    return 0
}

koopa::sra_prefetch() { # {{{1
    # """
    # Prefetch files from SRA (in parallel).
    # @note Updated 2022-02-10.
    #
    # @examples
    # > koopa::sra_prefetch \
    # >     --accession-file='srp049596-accession-list.txt' \
    # >     --output-directory='srp049596-prefetch'
    #
    # @seealso
    # - Conda build of sratools prefetch isn't currently working on macOS.
    #   https://github.com/ncbi/sra-tools/issues/497
    # """
    local app cmd dict
    declare -A app=(
        [parallel]="$(koopa::locate_parallel)"
        [prefetch]="$(koopa::locate_prefetch)"
    )
    declare -A dict=(
        [acc_file]=''
        [jobs]="$(koopa::cpu_count)"
        [output_dir]='sra'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--accession-file='*)
                dict[acc_file]="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict[acc_file]="${2:?}"
                shift 2
                ;;
            '--output-directory='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-directory')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set \
        '--accession-file' "${dict[acc_file]}" \
        '--output-directory' "${dict[output_dir]}"
    koopa::assert_is_file "${dict[acc_file]}"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    koopa::alert "Prefetching SRA files to '${dict[output_dir]}'."
    cmd=(
        "${app[prefetch]}"
        '--force' 'no'
        '--output-directory' "${dict[output_dir]}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    "${app[parallel]}" \
        --arg-file "${dict[acc_file]}" \
        --bar \
        --eta \
        --jobs "${dict[jobs]}" \
        --progress \
        --will-cite \
        "${cmd[*]}"
    return 0
}
