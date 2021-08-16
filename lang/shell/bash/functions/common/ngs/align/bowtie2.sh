#!/usr/bin/env bash

# NOTE Migrate this code to r-koopa package.
# FIXME Rework these using dict approaches.

koopa:::bowtie2_align() { # {{{1
    # """
    # Run bowtie2 alignment on multiple paired-end FASTQ files.
    # @note Updated 2021-08-16.
    # """
    local align_args fastq_r1 fastq_r1_bn fastq_r2 fastq_r2_bn id index_prefix
    local log_file output_dir r1_tail r2_tail sam_file sample_output_dir
    local tee threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'bowtie2'
    while (("$#"))
    do
        case "$1" in
            --fastq-r1=*)
                fastq_r1="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                fastq_r2="${1#*=}"
                shift 1
                ;;
            # FIXME Rename / consider reworking this.
            # FIXME Rework this as 'index-dir'.
            --index-prefix=*)
                index_prefix="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                r1_tail="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                r2_tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done


    koopa::assert_is_file "$fastq_r1" "$fastq_r2"
    fastq_r1_bn="$(koopa::basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"
    fastq_r2_bn="$(koopa::basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"
    koopa::assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"
    id="$fastq_r1_bn"
    sample_output_dir="${output_dir}/${id}"
    if [[ -d "$sample_output_dir" ]]
    then
        koopa::alert_note "Skipping '${id}'."
        return 0
    fi
    koopa::h2 "Aligning '${id}' into '${sample_output_dir}'."
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    sam_file="${sample_output_dir}/${id}.sam"
    log_file="${sample_output_dir}/bowtie2.log"
    koopa::mkdir "$sample_output_dir"
    tee="$(koopa::locate_tee)"
    align_args=(
        '--local'
        '--sensitive-local'
        '--rg-id' "$id"
        '--rg' 'PL:illumina'
        '--rg' "PU:${id}"
        '--rg' "SM:${id}"
        '--threads' "$threads"
        '-1' "$fastq_r1"
        '-2' "$fastq_r2"
        '-S' "$sam_file"
        '-X' 2000
        '-q'
        # FIXME Rename this to 'index_base'
        '-x' "$index_prefix"
    )
    koopa::dl 'Align args' "${align_args[*]}"
    bowtie2 "${align_args[@]}" 2>&1 | "$tee" "$log_file"
    return 0
}

koopa:::bowtie2_index() { # {{{1
    # """
    # Generate bowtie2 index.
    # @note Updated 2021-08-16.
    # """
    local app dict index_args
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'bowtie2-build'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note \
            "bowtie2 genome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa::h2 "Generating bowtie2 index at '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    # This step adds 'bowtie2.*' prefix to the files created in the output.
    dict[index_base]="${dict[output_dir]}/bowtie2"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--threads=${dict[threads]}"
        '--verbose'
        "${dict[fasta_file]}"
        "${dict[index_base]}"
    )
    koopa::dl 'Index args' "${index_args[*]}"
    bowtie2-build "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

# FIXME Need to nest 'index' and 'samples' under subdirectories.
koopa::run_bowtie2() { # {{{1
    # """
    # Run bowtie2 on a directory containing multiple FASTQ files.
    # @note Updated 2021-08-16.
    # """
    local app dict
    local fastq_r1_files r1_tail r2_tail str
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [fastq_dir]='fastq'
        [output_dir]='bowtie2'
        [r1_tail]='_R1_001.fastq.gz'
        [r2_tail]='_R2_001.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                dict[r1_tail]="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                dict[r2_tail]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running bowtie2.'
    koopa::activate_conda_env 'bowtie2'
    koopa::assert_is_file "${dict[fasta_file]}"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    # FIXME Rework this using 'init_dir' approach.
    koopa::mkdir "${dict[output_dir]}"
    dict[output_dir]="$(koopa::realpath "${dict[output_dir]}")"
    dict[index_dir]="${dict[output_dir]}/index"
    dict[index_base]="${dict[index_dir]}/bowtie2"
    dict[samples_dir]="${dict[output_dir]}/samples"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    # Pipe GNU find into array.
    readarray -t fastq_r1_files <<< "$( \
        "${app[find]}" "$fastq_dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type 'f' \
            -name "*${r1_tail}" \
            -print \
        | "${app[sort]}" \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        # FIXME Improve message consistency with salmon.
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[r1_tail]}'."
    fi
    str="$(koopa::ngettext "${#fastq_r1_files[@]}" 'sample' 'samples')"
    koopa::alert_info "${#fastq_r1_files[@]} ${str} detected."
    # Index {{{2
    # --------------------------------------------------------------------------
    koopa:::bowtie2_index \
        --fasta-file="$fasta_file" \
        --output-dir="${dict[index_dir]}"
    koopa::assert_is_dir "${dict[index_dir]}"
    # Alignment {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and align.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${dict[r1_tail]}/${dict[r2_tail]}}"
        # FIXME Ensure we've reworked 'index_base' in other calls.
        koopa:::bowtie2_align \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --index-base="${dict[index_base]}" \
            --output-dir="${dict[samples_dir]}" \
            --r1-tail="${dict[r1_tail]}" \
            --r2-tail="${dict[r2_tail]}"
    done
    koopa::alert_success 'bowtie alignment completed successfully.'
    return 0
}
