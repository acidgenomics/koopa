#!/usr/bin/env bash

koopa::_bam_filter() { # {{{1
    # """
    # Perform filtering on a BAM file.
    # @note Updated 2020-07-07.
    # @seealso
    # - https://lomereiter.github.io/sambamba/docs/sambamba-view.html
    # - https://github.com/lomereiter/sambamba/wiki/
    #       %5Bsambamba-view%5D-Filter-expression-syntax
    # - https://hbctraining.github.io/In-depth-NGS-Data-Analysis-Course/
    #       sessionV/lessons/03_align_and_filtering.html
    # """
    local filter input_bam input_bam_bn output_bam output_bam_bn threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed sambamba
    while (("$#"))
    do
        case "$1" in
            --filter=*)
                filter="${1#*=}"
                shift 1
                ;;
            --input-bam=*)
                input_bam="${1#*=}"
                shift 1
                ;;
            --output-bam=*)
                output_bam="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set filter input_bam output_bam
    koopa::assert_are_not_identical "$input_bam" "$output_bam"
    input_bam_bn="$(basename "$input_bam")"
    output_bam_bn="$(basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa::note "Skipping \"${output_bam_bn}\"."
        return 0
    fi
    koopa::h2 "Filtering \"${input_bam_bn}\" to \"${output_bam_bn}\"."
    koopa::assert_is_file "$input_bam"
    koopa::dl 'Filter' "$filter"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    # Note that sambamba prints version information into stderr.
    sambamba view \
        --filter="$filter" \
        --format='bam' \
        --nthreads="$threads" \
        --output-filename="$output_bam" \
        --show-progress \
        --with-header \
        "$input_bam"
    return 0
}

koopa::_bam_filter_duplicates() { # {{{1
    # """
    # Remove duplicates from a duplicate marked BAM file.
    # @note Updated 2020-07-01.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       bam/__init__.py
    # """
    koopa::assert_has_args "$#"
    koopa::_bam_filter --filter='not duplicate' "$@"
    return 0
}

koopa::_bam_filter_multimappers() { # {{{1
    # """
    # Filter multi-mapped reads from a BAM file.
    # @note Updated 2020-07-01.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       chipseq/__init__.py
    # """
    koopa::assert_has_args "$#"
    koopa::_bam_filter --filter='[XS] == null' "$@"
    return 0
}

koopa::_bam_filter_unmapped() { # {{{1
    # """
    # Filter unmapped reads from a BAM file.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    koopa::_bam_filter --filter='not unmapped' "$@"
    return 0
}

koopa::_bam_sort() { # {{{1
    # """
    # Sort a BAM file by genomic coordinates.
    # @note Updated 2020-07-07.
    #
    # Sorts by genomic coordinates by default.
    # Use '-n' flag to sort by read name instead.
    #
    # @seealso
    # - https://lomereiter.github.io/sambamba/docs/sambamba-sort.html
    # """
    local sorted_bam sorted_bam_bn threads unsorted_bam unsorted_bam_bn
    koopa::assert_has_args "$#"
    koopa::assert_is_installed sambamba
    unsorted_bam="${1:?}"
    sorted_bam="${unsorted_bam%.bam}.sorted.bam"
    unsorted_bam_bn="$(basename "$unsorted_bam")"
    sorted_bam_bn="$(basename "$sorted_bam")"
    if [[ -f "$sorted_bam" ]]
    then
        koopa::note "Skipping \"${sorted_bam_bn}\"."
        return 0
    fi
    koopa::h2 "Sorting \"${unsorted_bam_bn}\" to \"${sorted_bam_bn}\"."
    koopa::assert_is_file "$unsorted_bam"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "${threads}"
    # This is noisy and spits out program version information, so hiding stdout
    # and stderr. Note that simply using '> /dev/null' doesn't work here.
    sambamba sort \
        --memory-limit='2GB' \
        --nthreads="$threads" \
        --out="$sorted_bam" \
        --show-progress \
        "$unsorted_bam"
    return 0
}

koopa::_sam_to_bam() { # {{{1
    # """
    # Convert SAM file to BAM.
    # @note Updated 2020-07-08.
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
        koopa::note "Skipping \"${bam_bn}\"."
        return 0
    fi
    koopa::h2 "Converting \"${sam_bn}\" to \"${bam_bn}\"."
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

koopa::bam_filter() { # {{{1
    # """
    # Apply multi-step filtering to BAM files.
    # @note Updated 2020-07-01.
    # """
    local bam_file bam_files dir final_output_bam final_output_tail input_bam \
        input_tail output_bam output_tail
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(realpath "$dir")"
    # Pipe GNU find into array.
    readarray -t bam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname "*.sorted.bam" \
            -print \
        | sort \
    )"
    # Error if file array is empty.
    if ! koopa::is_array_non_empty "${bam_files[@]}"
    then
        koopa::stop "No BAM files detected in \"${dir}\"."
    fi
    koopa::h1 "Filtering BAM files in \"${dir}\"."
    koopa::activate_conda_env sambamba
    koopa::dl 'sambamba' "$(koopa::which_realpath sambamba)"
    # Performing filtering in multiple steps here.
    for bam_file in "${bam_files[@]}"
    do
        final_output_tail="filtered"
        final_output_bam="${bam_file%.bam}.${final_output_tail}.bam"
        if [[ -f "$final_output_bam" ]]
        then
            koopa::note "Skipping '$(basename "$final_output_bam")'."
            continue
        fi
        # Filter duplicate reads.
        input_bam="$bam_file"
        output_tail="filtered-1-no-duplicates"
        output_bam="${input_bam%.bam}.${output_tail}.bam"
        koopa::_bam_filter_duplicates \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # Filter unmapped reads.
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail="filtered-2-no-unmapped"
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa::_bam_filter_unmapped \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # Filter multimapping reads.
        # Note that this step can overfilter some samples with with large global
        # changes in chromatin state.
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail="filtered-3-no-multimappers"
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa::_bam_filter_multimappers \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # Copy the final result.
        koopa::cp "$output_bam" "$final_output_bam"
        # Index the final filtered BAM file.
        koopa::bam_index "$final_output_bam"
    done
    return 0
}

koopa::bam_index() { # {{{1
    # """
    # Index BAM file.
    # @note Updated 2020-07-01.
    # """
    local bam_file threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed samtools
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    for bam_file in "$@"
    do
        koopa::info "Indexing \"${bam_file}\"."
        koopa::assert_is_file "$bam_file"
        sambamba index \
            --nthreads="$threads" \
            --show-progress \
            "$bam_file"
    done
    return 0
}

koopa::bam_sort() { # {{{1
    # """
    # Sort BAM files.
    # @note Updated 2020-07-01.
    # """
    local bam_file bam_files dir
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(realpath "$dir")"
    # Pipe GNU find into array.
    readarray -t bam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname "*.bam" \
            -not -iname "*.filtered.*" \
            -not -iname "*.sorted.*" \
            -print \
        | sort \
    )"
    # Error if file array is empty.
    if ! koopa::is_array_non_empty "${bam_files[@]}"
    then
        koopa::stop "No BAM files detected in \"${dir}\"."
    fi
    koopa::h1 "Sorting BAM files in \"${dir}\"."
    koopa::activate_conda_env sambamba
    koopa::dl 'sambamba' "$(koopa::which_realpath sambamba)"
    for bam_file in "${bam_files[@]}"
    do
        koopa::_bam_sort "$bam_file"
    done
    return 0
}

koopa::copy_bam_files() { # {{{1
    # """
    # Copy BAM files.
    # @note Updated 2020-07-03.
    #
    # Intended primarily for use with bcbio-nextgen.
    # """
    local source_dir target_dir
    koopa::assert_has_args "$#"
    source_dir="$(realpath "${1:?}")"
    target_dir="$(realpath "${2:?}")"
    koopa::dl 'Source' "${source_dir}"
    koopa::dl 'Target' "${target_dir}"
    find -L "$source_dir" \
        -maxdepth 4 \
        -type f \
        \( -name "*.bam" -or -name "*.bam.bai" \) \
        ! -name "*-transcriptome.bam" \
        ! -path "*/work/*" \
        -print0 | xargs -0 -I {} \
            rsync --size-only --progress {} "${target_dir}/"
    return 0
}

koopa::sam_to_bam() {
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
            -iname "*.sam" \
            -print \
        | sort \
    )"
    # Error if file array is empty.
    if ! koopa::is_array_non_empty "${sam_files[@]}"
    then
        koopa::stop "No SAM files detected in \"${dir}\"."
    fi
    koopa::h1 "Converting SAM files in \"${dir}\" to BAM format."
    koopa::activate_conda_env samtools
    koopa::dl 'samtools' "$(koopa::which_realpath samtools)"
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

