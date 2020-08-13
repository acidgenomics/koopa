#!/usr/bin/env bash

# FIXME Need to rename internal functions.
koopa::sam_to_bam() { # {{{1
    # """
    # Convert SAM to BAM files.
    # @note Updated 2020-07-08.
    #
    # samtools view --help
    # Useful flags:
    # -1                    use fast BAM compression (implies -b)
    # -@, --threads         number of threads
    # -C                    output CRAM (requires -T)
    # -O, --output-fmt      specify output format (SAM, BAM, CRAM)
    # -T, --reference       reference sequence FASTA file
    # -b                    output BAM
    # -o FILE               output file name [stdout]
    # -u                    uncompressed BAM output (implies -b)
    # """
    local bam_file keep_sam pos sam_file sam_files
    keep_sam=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --keep-sam)
                keep_sam=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(realpath "$dir")"
    # Pipe GNU find into array.
    readarray -t sam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.sam' \
            -print \
        | sort \
    )"
    # Error if file array is empty.
    if ! koopa::is_array_non_empty "${sam_files[@]}"
    then
        koopa::stop "No SAM files detected in '${dir}'."
    fi
    koopa::h1 "Converting SAM files in '${dir}' to BAM format."
    koopa::activate_conda_env samtools
    case "$keep_sam" in
        0)
            koopa::note 'SAM files will be deleted.'
            ;;
        1)
            koopa::note 'SAM files will be preserved.'
            ;;
    esac
    for sam_file in "${sam_files[@]}"
    do
        bam_file="${sam_file%.sam}.bam"
        koopa::_sam_to_bam \
            --input-sam="$sam_file" \
            --output-bam="$bam_file"
        [[ "$keep_sam" -eq 0 ]] && koopa::rm "$sam_file"
    done
    return 0
}


# FIXME Previously named _sam_to_bam
koopa::samtools_convert_sam_to_bam() { # {{{1
    # """
    # Convert SAM file to BAM.
    # @note Updated 2020-08-12.
    # """
    local bam_bn sam_bn threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed samtools
    while (("$#"))
    do
        case "$1" in
            --input-sam=*)
                local input_sam="${1#*=}"
                shift 1
                ;;
            --output-bam=*)
                local output_bam="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set input_sam output_bam
    sam_bn="$(basename "$input_sam")"
    bam_bn="$(basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa::note "Skipping '${bam_bn}'."
        return 0
    fi
    koopa::h2 "Converting '${sam_bn}' to '${bam_bn}'."
    koopa::assert_is_file "$input_sam"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    samtools view \
        -@ "$threads" \
        -b \
        -h \
        -o "$output_bam" \
        "$input_sam"
    return 0
}
