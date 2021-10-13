#!/usr/bin/env bash

# FIXME Consider renaming this function, prefixing with 'sra-'.
# FIXME Need to compress FASTQ files here.
# FIXME Allow the user to set FASTQ output and SRA input targets.
# FIXME Allow the user to pass in temp directory
# FIXME Allow the user to set '--compress' or '--no-compress' overrides.
koopa::sra_fastq_dump_parallel() { # {{{1
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
    local dict
    local acc_file fastq_dir gzip id sort sra_dir sra_file sra_files threads
    # FIXME Rework the argparse here
    koopa::assert_has_args_le "$#" 1
    declare -A dict=(
        # FIXME Allow override with '--no-compress'
        [compress]=1
    )
    
    # FIXME Rework this to merely locate the program directly instead.
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
    gzip="$(koopa::locate_gzip)"
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
            koopa::alert "Extracting FASTQ in '${sra_file}'."
            koopa::dl \
                'SRA accession' "$id" \
                'SRA file' "$sra_file"
            # FIXME Can we locate this program without activating conda
            # and/or Homebrew prefix? Simpler. Think about this one.
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

    # FIXME Look in FASTQ target directory and gzip and uncompressed files.
    # FIXME Run gzip compression here in parallel if we detect any uncompressed
    # FASTQ files.
    # FIXME Alert the user that we are compressing specific files...
    echo "$gzip"  # FIXME

    # FIXME placeholder parallel gzip code:
    # > find . -mindepth 1 -maxdepth 1 -name '*.fastq' \
    # >     | parallel --bar --eta --jobs 8 --progress --will-cite \
    # >         'gzip --force --verbose {}'

    if koopa::is_macos
    then
        echo 'FIXME Need to deactivate Homebrew prefix.'
    else
        koopa::deactivate_conda
    fi
    return 0
}

# FIXME Allow the user to set target directory.
# FIXME Allow the user to set 'accession-file' argument.
koopa::sra_prefetch_parallel() { # {{{1
    # """
    # Prefetch files from SRA in parallel with Aspera.
    # @note Updated 2021-10-13.
    #
    # @seealso
    # - Conda build isn't currently working on macOS.
    #   https://github.com/ncbi/sra-tools/issues/497
    # """
    local acc_file cmd dir jobs parallel
    # FIXME Rework the argparse, similar to FASTQ dump function above.
    koopa::assert_has_args_le "$#" 1
    acc_file="${1:-}"
    [[ -z "$acc_file" ]] && acc_file='SRR_Acc_List.txt'
    koopa::assert_is_file "$acc_file"

    # FIXME Rework this to merely locate the program directly instead.
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
    # FIXME Rework this an an internal koopa function.
    "$parallel" \
        --arg-file "$acc_file" \
        --bar \
        --eta \
        --jobs "$jobs" \
        --progress \
        --will-cite \
        "${cmd[*]}"
    # FIXME If we locate program directly, this step will be unnecessary.
    if koopa::is_macos
    then
        echo 'FIXME deactivate homebrew opt prefix'
    else
        koopa::deactivate_conda
    fi
    return 0
}
