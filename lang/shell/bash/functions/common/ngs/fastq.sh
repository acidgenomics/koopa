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
