#!/usr/bin/env bash

# NOTE Need to migrate these functions to r-koopa.

koopa::convert_fastq_to_fasta() { # {{{1
    # """
    # Convert FASTQ files into FASTA format.
    # @note Updated 2021-09-21.
    #
    # Alternate approaches:
    #
    # > seqtk seq -A
    # > bioawk -c fastx '{print ">" $name; print $seq}' "$fastq_file"
    # > cat "$fastq_file" \
    # >     | paste - - - - \
    # >     | awk -v FS="\t" '{print $1"\n"$2}' \
    # >     > "$fasta_file"
    # """
    local array cut fasta_file fastq_file paste sed source_dir target_dir tr
    koopa::assert_has_args "$#"
    cut="$(koopa::locate_cut)"
    paste="$(koopa::locate_paste)"
    sed="$(koopa::locate_sed)"
    tr="$(koopa::locate_tr)"
    source_dir='.'
    target_dir='.'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--source-dir='*)
                source_dir="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                source_dir="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                target_dir="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                target_dir="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "$source_dir"
    source_dir="$(koopa::strip_trailing_slash "$source_dir")"
    target_dir="$(koopa::strip_trailing_slash "$target_dir")"
    # Pipe GNU find into array.
    readarray -t array <<< "$( \
        koopa::find \
            --glob='*.fastq' \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="$source_dir" \
            --type='f' \
        | sort \
    )"
    [[ "${#array[@]}" -eq 0 ]] && koopa::stop 'No FASTQ files detected.'
    koopa::mkdir "$target_dir"
    for fastq_file in "${array[@]}"
    do
        fasta_file="${fastq_file%.fastq}.fasta"
        "$paste" - - - - < "$fastq_file" \
            | "$cut" -f 1,2 \
            | "$sed" 's/^@/>/' \
            | "$tr" '\t' '\n' > "$fasta_file"
    done
    return 0
}

# FIXME Consider renaming this function, prefixing with 'sra-'.
# FIXME Need to compress FASTQ files here.
koopa::fastq_dump_from_sra_file_list() { # {{{1
    # """
    # Dump FASTQ files from SRA file list.
    # @note Updated 2021-10-13.
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
    # """
    local acc_file fastq_dir id sort sra_dir sra_file sra_files threads
    koopa::assert_has_args_le "$#" 1
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'sratoolkit'
    else
        koopa::activate_conda_env 'sra-tools'
    fi
    koopa::assert_is_installed 'fasterq-dump'
    acc_file="${1:-}"
    [[ -z "$acc_file" ]] && acc_file='SRR_Acc_List.txt'
    koopa::assert_is_file "$acc_file"
    fastq_dir='fastq'
    sra_dir='sra'
    if [[ ! -d "$sra_dir" ]]
    then
        koopa::sra_prefetch_parallel "$acc_file"
    fi
    koopa::assert_is_dir "$sra_dir"
    sort="$(koopa::locate_sort)"
    # FIXME Rework 'koopa::find' to support '--sort' natively.
    readarray -t sra_files <<< "$(
        koopa::find \
            --glob='*.sra' \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="$sra_dir" \
        | "$sort" \
    )"
    koopa::assert_is_array_non_empty "${sra_files[@]:-}"
    threads="$(koopa::cpu_count)"
    for sra_file in "${sra_files[@]}"
    do
        id="$(koopa::basename_sans_ext "$sra_file")"
        if [[ ! -f "${fastq_dir}/${id}.fastq" ]] && \
            [[ ! -f "${fastq_dir}/${id}_1.fastq" ]] && \
            [[ ! -f "${fastq_dir}/${id}.fastq.gz" ]] && \
            [[ ! -f "${fastq_dir}/${id}_1.fastq.gz" ]]
        then
            koopa::dl 'SRA Accession ID' "$id"
            fasterq-dump \
                --details \
                --force \
                --outdir "$fastq_dir" \
                --print-read-nr \
                --progress \
                --skip-technical \
                --split-3 \
                --strict \
                --threads "$threads" \
                --verbose \
                "${id}"
        fi
    done
    if koopa::is_macos
    then
        echo 'FIXME Need to deactivate Homebrew prefix.'
    else
        koopa::deactivate_conda
    fi
    return 0
}

koopa::fastq_lanepool() { # {{{1
    # """
    # Pool lane-split FASTQ files.
    # @note Updated 2021-09-21.
    # """
    local array basenames cat find head i out prefix source_dir sort
    local tail target_dir
    cat="$(koopa::locate_cat)"
    find="$(koopa::locate_find)"
    sort="$(koopa::locate_sort)"
    prefix='lanepool'
    source_dir='.'
    target_dir='.'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                prefix="${1#*=}"
                shift 1
                ;;
            '--prefix')
                prefix="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                source_dir="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                source_dir="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                target_dir="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                target_dir="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    source_dir="$(koopa::strip_trailing_slash "$source_dir")"
    target_dir="$(koopa::strip_trailing_slash "$target_dir")"
    # Pipe GNU find into array.
    readarray -t array <<< "$( \
        "$find" "$source_dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type 'f' \
            -iname '*_L001_*.fastq*' \
            -print \
        | "$sort" \
    )"
    # Error if file array is empty.
    if [[ "${#array[@]}" -eq 0 ]]
    then
        koopa::stop 'No lane-split FASTQ files detected.'
    fi
    koopa::mkdir "$target_dir"
    basenames=()
    for i in "${array[@]}"
    do
        basenames+=("$(basename "$i")")
    done
    head=()
    for i in "${basenames[@]}"
    do
        i="${i//_L001_*/}"
        head+=("$i")
    done
    tail=()
    for i in "${basenames[@]}"
    do
        i="${i//*_L001_/}"
        tail+=("$i")
    done
    out=()
    for i in "${basenames[@]}"
    do
        i="${i//_L001/}"
        i="${target_dir}/${prefix}_${i}"
        out+=("$i")
    done
    # Loop across the array indices, similar to 'mapply()' approach in R.
    for i in "${!out[@]}"
    do
        "$cat" "${source_dir}/${head[i]}_L00"[1-9]"_${tail[i]}" > "${out[i]}"
    done
    return 0
}

koopa::fastq_reads_per_file() { # {{{1
    # """
    # Determine the number of reads per FASTQ file.
    # @note Updated 2021-09-21.
    # """
    local awk dir wc zcat
    awk="$(koopa::locate_awk)"
    wc="$(koopa::locate_wc)"
    zcat="$(koopa::locate_zcat)"
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    # Divide by 4.
    # shellcheck disable=SC2016
    "$zcat" "${dir}/"*'_R1.fastq.gz' \
        | "$wc" -l \
        | "$awk" '{print $1/4}'
    return 0
}

koopa::sra_prefetch_parallel() { # {{{1
    # """
    # Prefetch files from SRA in parallel with Aspera.
    # @note Updated 2021-10-13.
    #
    # @seealso
    # - Conda build isn't currently working on macOS.
    #   https://github.com/ncbi/sra-tools/issues/497
    # """
    local acc_file cmd dir find jobs parallel
    koopa::assert_has_args_le "$#" 1
    acc_file="${1:-}"
    [[ -z "$acc_file" ]] && acc_file='SRR_Acc_List.txt'
    koopa::assert_is_file "$acc_file"
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'sratoolkit'
    else
        koopa::activate_conda_env 'sra-tools'
    fi
    koopa::assert_is_installed 'prefetch'
    jobs="$(koopa::cpu_count)"
    parallel="$(koopa::locate_parallel)"
    sort="$(koopa::locate_sort)"
    dir="$(koopa::init_dir 'sra')"
    cmd=(
        'prefetch'
        '--force' 'no'
        '--output-directory' "${dir}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    "$parallel" \
        --arg-file "$acc_file" \
        --bar \
        --eta \
        --jobs "$jobs" \
        --progress \
        --will-cite \
        "${cmd[*]}"
    if koopa::is_macos
    then
        echo 'FIXME deactivate homebrew opt prefix'
    else
        koopa::deactivate_conda
    fi
    return 0
}
