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

# FIXME Should this use 'sra-tools' conda environment?
# FIXME Allow user to set the target directory?
# FIXME Call prefetch here first.
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
    # - koopa::aspera_sra_prefetch_parallel
    # - https://rnnh.github.io/bioinfo-notebook/docs/fasterq-dump.html
    # - https://edwards.sdsu.edu/research/the-perils-of-fasterq-dump/
    # """
    local file id
    koopa::assert_has_no_args "$#"

    # FIXME Prefetch via our sra_prefetch_parallel function here first.

    koopa::activate_conda_env 'sra-tools'
    koopa::assert_is_installed 'fasterq-dump'
    file="${1:-}"
    [[ -z "$file" ]] && file='SRR_Acc_List.txt'
    koopa::assert_is_file "$file"

    ## FIXME Call aspera_sra_prefetch_parallel first here, if no SRA files
    ## are detected in the current directory.
    ## FIXME Double check extensions for fasterq-dump.

    while read -r id
    do
        if [[ ! -f "${id}.fastq.gz" ]] && [[ ! -f "${id}_1.fastq.gz" ]]
        then
            koopa::dl 'SRA Accession ID' "$id"
            # Consider testing:
            # * --clip
            # * --read-filter 'pass'
            fasterq-dump \
                --outdir '.' \
                --print-read-nr \
                --skip-technical \
                --split-3 \
                "${id}"
        fi
    done < "$file"
    koopa::deactivate_conda
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
    local cmd dir file find jobs parallel sort
    file="${1:-}"
    [[ -z "$file" ]] && file='SRR_Acc_List.txt'
    koopa::assert_is_file "$file"
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
    "$sort" -u "$file" | "$parallel" -j "$jobs" "${cmd[*]}"
    if koopa::is_macos
    then
        echo 'FIXME deactivate homebrew opt prefix'
    else
        koopa::deactivate_conda
    fi
    return 0
}
