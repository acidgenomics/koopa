#!/usr/bin/env bash

# Main functions ===============================================================
koopa::run_salmon_paired_end() { # {{{1
    # """
    # Run salmon on multiple paired-end FASTQ files.
    # @note Updated 2022-01-11.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local app dict
    local fastq_r1_files fastq_r1_file fastq_r2_file str
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [salmon]="$(koopa::locate_conda_salmon)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fasta_file]=''
        [fastq_dir]='fastq'
        [fastq_r1_tail]='_R1_001.fastq.gz'
        [fastq_r2_tail]='_R2_001.fastq.gz'
        [gff_file]=''
        [index_dir]='salmon/index'
        [lib_type]='A'
        [output_dir]='salmon/samples'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running salmon (paired-end mode).'
    koopa::assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fasta-file' "${dict[fasta_file]}" \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-tail' "${dict[fastq_r1_tail]}" \
        '--gff-file' "${dict[gff_file]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    dict[gff_file]="$(koopa::realpath "${dict[gff_file]}")"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    koopa::dl \
        'salmon' "${app[salmon]}" \
        'Bootstraps' "${dict[bootstraps]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ R1 tail' "${dict[fastq_r1_tail]}" \
        'FASTQ R2 tail' "${dict[fastq_r2_tail]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF/GTF file' "${dict[gff_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'Threads' "${dict[threads]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    readarray -t fastq_r1_files <<< "$( \
        koopa::find \
            --glob="*${dict[fastq_r1_tail]}" \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[fastq_r1_tail]}'."
    fi
    str="$(koopa::ngettext "${#fastq_r1_files[@]}" 'sample' 'samples')"
    koopa::alert_info "${#fastq_r1_files[@]} ${str} detected."
    # Index {{{2
    # --------------------------------------------------------------------------
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa::salmon_index \
            --fasta-file="${dict[fasta_file]}" \
            --no-decoy-aware \
            --output-dir="${dict[index_dir]}" \
            --threads="${dict[threads]}"
    fi
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        fastq_r2_file="${fastq_r1_file/\
${dict[fastq_r1_tail]}/${dict[fastq_r2_tail]}}"
        koopa::salmon_quant_paired_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq-r1-file="$fastq_r1_file" \
            --fastq-r1-tail="${dict[fastq_r1_tail]}" \
            --fastq-r2-file="$fastq_r2_file" \
            --fastq-r2-tail="${dict[fastq_r2_tail]}" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}" \
            --threads="${dict[threads]}"
    done
    koopa::alert_success "salmon run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

koopa::run_salmon_single_end() { # {{{1
    # """
    # Run salmon on multiple single-end FASTQ files.
    # @note Updated 2022-01-11.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # Attempting to detect library type (strandedness) automatically by default.
    # """
    local app dict
    local fastq_file fastq_files str
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [salmon]="$(koopa::locate_conda_salmon)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [fastq_tail]='.fastq.gz'
        [index_dir]='salmon/index'
        [lib_type]='A'
        [output_dir]='salmon/samples'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running salmon (single-end mode).'
    koopa::assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fasta-file' "${dict[fasta_file]}" \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--gff-file' "${dict[gff_file]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    dict[gff_file]="$(koopa::realpath "${dict[gff_file]}")"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    koopa::dl \
        'salmon' "${app[salmon]}" \
        'Bootstraps' "${dict[bootstraps]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'GFF/GTF file' "${dict[gff_file]}" \
        'Index dir' "${dict[index_dir]}" \
        'Output dir' "${dict[output_dir]}" \
        'Threads' "${dict[threads]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the FASTQ files.
    readarray -t fastq_files <<< "$( \
        koopa::find \
            --glob="*${dict[fastq_tail]}" \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[fastq_tail]}'."
    fi
    str="$(koopa::ngettext "${#fastq_files[@]}" 'sample' 'samples')"
    koopa::alert_info "${#fastq_files[@]} ${str} detected."
    # Index {{{2
    # --------------------------------------------------------------------------
    if [[ ! -d "${dict[index_dir]}" ]]
    then
        koopa::salmon_index \
            --fasta-file="${dict[fasta_file]}" \
            --no-decoy-aware \
            --output-dir="${dict[index_dir]}" \
            --threads="${dict[threads]}"
    fi
    koopa::assert_is_dir "${dict[index_dir]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with salmon.
    for fastq_file in "${fastq_files[@]}"
    do
        koopa::salmon_quant_single_end \
            --bootstraps="${dict[bootstraps]}" \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --gff-file="${dict[gff_file]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}" \
            --threads="${dict[threads]}"
    done
    koopa::alert_success "salmon run at '${dict[output_dir]}' \
completed successfully."
    return 0
}

# Individual runners ===========================================================

# FIXME Compare results of original script to our function, and confirm that
#       output is consistent, before proceeding.

koopa::salmon_generate_decoy_transcriptome() { # {{{1
    # """
    # Generate decoy transcriptome for salmon index.
    # @note Updated 2022-01-11.
    #
    # @section Documentation on original COMBINE lab script:
    #
    # generateDecoyTranscriptome.sh: This is a preprocessing script for creating
    # augmented hybrid FASTA file for 'salmon index'. It consumes a genome
    # FASTA, transcriptome FASTA, and the annotation GTF file to create a new
    # hybrid FASTA file which contains the decoy sequences from the genome,
    # concatenated with the transcriptome, resulting in 'gentrome.fa'. It runs
    # mashmap to align transcriptome to an exon masked genome, with 80%
    # homology, and extracts the mapped genomic interval. It uses awk and
    # bedtools to merge the contiguosly mapped interval, and extracts decoy
    # sequences from the genome. It also dumps 'decoys.txt' file, which contains
    # the name/identifier of the decoy sequences. Both 'gentrome.fa' and
    # 'decoys.txt' can be used with 'salmon index' with salmon >=0.14.0.
    #
    # @section Arguments from original COMBINE lab script:
    #
    # * [-j <N> =1 default]
    # * [-b <bedtools binary path> =bedtools default]
    # * [-m <mashmap binary path> =mashmap default]
    # * -a <gtf file>
    # * -g <genome fasta>
    # * -t <txome fasta>
    # * -o <output path>
    #
    # @seealso
    # - https://github.com/COMBINE-lab/SalmonTools/blob/master/
    #       scripts/generateDecoyTranscriptome.sh
    # - https://github.com/COMBINE-lab/SalmonTools/blob/master/README.md
    # - https://salmon.readthedocs.io/en/latest/
    #       salmon.html#quantifying-in-mapping-based-mode
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       rnaseq/salmon.py#L244
    # - https://github.com/marbl/MashMap/
    # """
    local app dict
    koopa::assert_has_args "$#"
    # Linux check currently required until Bioconda recipe is fixed for macOS.
    # See issue:
    # https://github.com/bioconda/bioconda-recipes/issues/32329
    koopa::assert_is_linux
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [bedtools]="$(koopa::locate_conda_bedtools)"
        [cat]="$(koopa::locate_cat)"
        [grep]="$(koopa::locate_grep)"
        [mashmap]="$(koopa::locate_conda_mashmap)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [compress_ext_pattern]="$(koopa::compress_ext_pattern)"
        [genome_fasta_file]=''
        [gtf_file]=''
        [output_dir]='salmon/index'
        [threads]="$(koopa::cpu_count)"
        [tmp_dir]="$(koopa::tmp_dir)"
        [transcriptome_fasta_file]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    koopa::assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[gtf_file]}" \
        "${dict[transcriptome_fasta_file]}"
    dict[genome_fasta_file]="$(koopa::realpath "${dict[genome_fasta_file]}")"
    dict[gtf_file]="$(koopa::realpath "${dict[genome_fasta_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa::realpath "${dict[transcriptome_fasta_file]}" \
    )"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    koopa::dl \
        'GTF file' "${dict[gtf_file]}" \
        'Genome FASTA file' "${dict[genome_fasta_file]}" \
        'Output dir' "${dict[output_dir]}" \
        'Threads' "${dict[threads]}" \
        'Transcriptome FASTA file' "${dict[transcriptome_fasta_file]}"
    (
        local dict2
        declare -A dict2=(
            [decoys_fasta_file]='decoys.fa'
            [decoys_txt_file]='decoys.txt'
            [exons_bed_file]='exons.bed'
            [genome_fasta_file]="$( \
                koopa::basename "${dict[genome_fasta_file]}" \
            )"
            [genome_found_fasta_file]='genome-found.fa'
            [genome_found_merged_bed_file]='genome-found-merged.bed'
            [genome_found_sorted_bed_file]='genome-found-sorted.bed'
            [gentrome_fasta_file]='gentrome.fa'
            [gtf_file]="$( \
                koopa::basename "${dict[gtf_file]}" \
            )"
            [mashmap_output_file]='mashmap.out'
            [masked_genome_fasta_file]='reference-masked-genome.fa'
            [transcriptome_fasta_file]="$(\
                koopa::basename "${dict[transcriptome_fasta_file]}" \
            )"
        )
        koopa::cd "${dict[tmp_dir]}"
        koopa::cp \
            "${dict[genome_fasta_file]}" \
            "${dict2[genome_fasta_file]}"
        koopa::cp \
            "${dict[gtf_file]}" \
            "${dict2[gtf_file]}"
        koopa::cp \
            "${dict[transcriptome_fasta_file]}" \
            "${dict2[transcriptome_fasta_file]}"
        # Decompress / extract compressed files, if necessary.
        if koopa::str_detect_regex \
            "${dict2[genome_fasta_file]}" \
            "${dict[compress_ext_pattern]}"
        then
            koopa::extract "${dict2[genome_fasta_file]}"
            dict2[genome_fasta_file]="$( \
                koopa::sub \
                    "${dict[compress_ext_pattern]}" '' \
                    "${dict2[genome_fasta_file]}" \
            )"
        fi
        if koopa::str_detect_regex \
            "${dict2[gtf_file]}" \
            "${dict[compress_ext_pattern]}"
        then
            koopa::extract "${dict2[gtf_file]}"
            dict2[gtf_file]="$( \
                koopa::sub \
                    "${dict[compress_ext_pattern]}" '' \
                    "${dict2[gtf_file]}" \
            )"
        fi
        if koopa::str_detect_regex \
            "${dict2[transcriptome_fasta_file]}" \
            "${dict[compress_ext_pattern]}"
        then
            koopa::extract "${dict2[transcriptome_fasta_file]}"
            dict2[transcriptome_fasta_file]="$( \
                koopa::sub \
                    "${dict[compress_ext_pattern]}" '' \
                    "${dict2[transcriptome_fasta_file]}" \
            )"
        fi
        koopa::assert_is_file \
            "${dict2[genome_fasta_file]}" \
            "${dict2[gtf_file]}" \
            "${dict2[transcriptome_fasta_file]}"
        # FIXME Take this out, once we test.
        koopa::dl \
            'GTF file' "${dict2[gtf_file]}" \
            'Genome FASTA file' "${dict2[genome_fasta_file]}" \
            'Transcriptome FASTA file' "${dict2[transcriptome_fasta_file]}"
        koopa::stop 'FIXME Check that files are correct here.'
        koopa::alert 'Extracting exonic features from the GTF.'
        # shellcheck disable=SC2016
        "${app[awk]}" -v OFS='\t' \
            '{if ($3=="exon") {print $1,$4,$5}}' \
            "${dict2[gtf_file]}" > "${dict2[exons_bed_file]}"
        koopa::alert 'Masking the genome FASTA.'
        "${app[bedtools]}" maskfasta \
            -bed "${dict2[exons_bed_file]}" \
            -fi "${dict2[genome_fasta_file]}" \
            -fo "${dict2[masked_genome_fasta_file]}"
        koopa::alert 'Aligning transcriptome to genome.'
        "${app[mashmap]}" \
            --filter_mode 'map' \
            --kmer 16 \
            --output "${dict2[mashmap_output_file]}" \
            --perc_identity 80 \
            --query "${dict2[transcriptome_fasta_file]}" \
            --ref "${dict2[masked_genome_fasta_file]}" \
            --segLength 500 \
            --threads "${dict[threads]}"
        koopa::assert_is_file "${dict2[mashmap_output_file]}"
        koopa::alert 'Extracting intervals from mashmap alignments.'
        # shellcheck disable=SC2016
        "${app[awk]}" -v OFS='\t' \
            '{print $6,$8,$9}' \
            "${dict2[mashmap_output_file]}" \
            | "${app[sort]}" -k1,1 -k2,2n - \
            > "${dict2[genome_found_sorted_bed_file]}"
        koopa::alert 'Merging the intervals.'
        "${app[bedtools]}" merge \
            -i "${dict2[genome_found_sorted_bed_file]}" \
            > "${dict2[genome_found_merged_bed_file]}"
        koopa::alert 'Extracting sequences from the genome.'
        "${app[bedtools]}" getfasta \
            -bed "${dict2[genome_found_merged_bed_file]}" \
            -fi "${dict2[masked_genome_fasta_file]}" \
            -fo "${dict2[genome_found_fasta_file]}"
        koopa::alert 'Concatenating FASTA to get decoy sequences.'
        # FIXME How to fix this to 80 character width limit?
        # shellcheck disable=SC2016
        "${app[awk]}" '{a=$0; getline;split(a, b, ":");  r[b[1]] = r[b[1]]""$0} END { for (k in r) { print k"\n"r[k] } }' \
            "${dict2[genome_found_fasta_file]}" \
            > "${dict2[decoys_fasta_file]}"
        koopa::alert 'Making gentrome FASTA file.'
        "${app[cat]}" \
            "${dict2[transcriptome_fasta_file]}" \
            "${dict2[decoys_fasta_file]}" \
            > "${dict2[gentrome_fasta_file]}"
        koopa::alert 'Extracting decoy sequence identifiers.'
        # shellcheck disable=SC2016
        "${app[grep]}" '>' "${dict2[decoys_fasta_file]}" \
            | "${app[awk]}" '{print substr($1,2); }' \
            > "${dict2[decoys_txt_file]}"
        koopa::cp \
            "${dict2[gentrome_fasta_file]}" \
            "${dict[output_dir]}/${dict2[gentrome_fasta_file]}"
        koopa::cp \
            "${dict2[decoys_txt_file]}" \
            "${dict[output_dir]}/${dict2[decoys_txt_file]}"
    )
    koopa::rm "${dict[tmp_dir]}"
    return 0
}

koopa::salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2022-01-11.
    #
    # @section FASTA conventions:
    #
    # FASTA file input here corresponds to transcriptome FASTA, not genome
    # primary assembly FASTA.
    #
    # @section GENCODE:
    #
    # Need to pass '--gencode' flag here for GENCODE reference genome.
    # Function attempts to detect this automatically from the file name.
    #
    # @section Decoy-aware transcriptome:
    #
    # Don't attempt to process decoy-aware transcriptome by default on macOS.
    # Bioconda mashmap recipe currently only works on Linux.
    #
    # Compare with bcbio-nextgen code:
    # https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/salmon.py
    #
    # @section Function export:
    #
    # Consider exporting this function as command-line-accessible
    # 'salmon-index'? May be too confusing, so not enabled at the moment.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa::locate_conda_salmon)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [decoy_aware]=0
        [fasta_file]=''
        [gencode]=0
        [kmer_length]=31
        [output_dir]='salmon/index'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--kmer-length='*)
                dict[kmer_length]="${1#*=}"
                shift 1
                ;;
            '--kmer-length')
                dict[kmer_length]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--decoy-aware')
                dict[decoy_aware]=1
                shift 1
                ;;
            '--gencode')
                dict[gencode]=1
                shift 1
                ;;
            '--no-decoy-aware')
                dict[decoy_aware]=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--fasta-file' "${dict[fasta_file]}" \
        '--kmer-length' "${dict[kmer_length]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    koopa::assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note \
            "Salmon transcriptome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa::h2 "Generating salmon index at '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--index=${dict[output_dir]}"
        "--kmerLen=${dict[kmer_length]}"
        "--threads=${dict[threads]}"
        "--transcripts=${dict[fasta_file]}"
    )
    # Automatically detect GENCODE genome, when applicable.
    if koopa::str_detect "$(koopa::basename "${dict[fasta_file]}")" '^gencode\.'
    then
        dict[gencode]=1
    fi
    if [[ "${dict[gencode]}" -eq 1 ]]
    then
        koopa::alert_info 'Indexing against GENCODE reference genome.'
        index_args+=('--gencode')
    fi
    if [[ "${dict[decoy_aware]}" -eq 1 ]]
    then
        koopa::stop 'FIXME Need to add support for this.'
        # FIXME Need to rework this once we get our modified mashmap function working.
        koopa::salmon_generate_decoy_transcriptome \
            --genome-fasta-file='FIXME' \
            --gtf-file='FIXME' \
            --output-dir='FIXME' \
            --transcriptome-fasta-file='FIXME'
        dict[decoys_file]='FIXME_OUTPUT_DIR/decoys.txt'
        koopa::assert_is_file "${dict[decoys_file]}"
        # FIXME Check that this is right convention.
        index_args+=("--decoys=${dict[decoys_file]}")
    fi
    koopa::dl 'Index args' "${index_args[*]}"
    "${app[salmon]}" index "${index_args[@]}" \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    koopa::alert_success "Indexing of '${dict[fasta_file]}' at \
'${dict[output_dir]}' was successful."
    return 0
}

koopa::salmon_quant_paired_end() { # {{{1
    # """
    # Run salmon quant (per paired-end sample).
    # @note Updated 2022-01-11.
    #
    # Quartz is currently using only '--validateMappings' and '--gcBias' flags.
    #
    # Important options:
    # * --libType='A': Enable ability to automatically infer (i.e. guess) the
    #   library type based on how the first few thousand reads map to the
    #   transcriptome. Note that most commercial vendors use Illumina TruSeq,
    #   which is dUTP, corresponding to 'ISR' for salmon.
    # * --validateMappings: Enables selective alignment of the sequencing reads
    #   when mapping them to the transcriptome. This can improve both the
    #   sensitivity and specificity of mapping and, as a result, can improve
    #   quantification accuracy.
    # * --numBootstraps: Compute bootstrapped abundance estimates. This is done
    #   by resampling (with replacement) from the counts assigned to the
    #   fragment equivalence classes, and then re-running the optimization
    #   procedure.
    # * --seqBias: Enable salmon to learn and correct for sequence-specific
    #   biases in the input data. Specifically, this model will attempt to
    #   correct for random hexamer priming bias, which results in the
    #   preferential sequencing of fragments starting with certain nucleotide
    #   motifs.
    # * --gcBias: Learn and correct for fragment-level GC biases in the input
    #   data. Specifically, this model will attempt to correct for biases in how
    #   likely a sequence is to be observed based on its internal GC content.
    # * --posBias: Experimental. Enable modeling of a position-specific fragment
    #   start distribution. This is meant to model non-uniform coverage biases
    #   that are sometimes present in RNA-seq data (e.g. 5' or 3' positional
    #   bias).
    #
    # Consider use of '--numGibbsSamples' instead of '--numBootstraps'.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       rnaseq/salmon.py
    # - How to output pseudobams:
    #   https://github.com/COMBINE-lab/salmon/issues/38
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa::locate_conda_salmon)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_r1_file]=''
        [fastq_r1_tail]='_R1_001.fastq.gz'
        [fastq_r2_file]=''
        [fastq_r2_tail]='_R2_001.fastq.gz'
        [gff_file]=''
        [index_dir]='salmon/index'
        [lib_type]='A'
        [output_dir]='salmon/samples'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict[fastq_r1_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict[fastq_r1_tail]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict[fastq_r2_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict[fastq_r2_tail]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--fastq-r1-tail' "${dict[fastq_r1_tail]}" \
        '--fastq-r2-file' "${dict[fastq_r2_file]}" \
        '--fastq-r2-tail' "${dict[fastq_r2_tail]}" \
        '--gff-file' "${dict[gff_file]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    koopa::assert_is_file \
        "${dict[fastq_r1_file]}" \
        "${dict[fastq_r2_file]}" \
        "${dict[gff_file]}"
    koopa::assert_is_dir "${dict[index_dir]}"
    dict[fastq_r1_bn]="$(koopa::basename "${dict[fastq_r1_file]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[fastq_r1_tail]}/}"
    dict[fastq_r2_bn]="$(koopa::basename "${dict[fastq_r2_file]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[fastq_r2_tail]}/}"
    koopa::assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa::h2 "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[log_file]="${dict[output_dir]}/quant.log"
    # Writing mappings to SAM file blows up disk space too much.
    # > dict[sam_file]="${dict[output_dir]}/output.sam"
    quant_args=(
        '--gcBias'
        "--geneMap=${dict[gff_file]}"
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--mates1=${dict[fastq_r1_file]}"
        "--mates2=${dict[fastq_r2_file]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        # > "--writeMappings=${dict[sam_file]}"
    )
    koopa::dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}" \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

koopa::salmon_quant_single_end() { # {{{1
    # """
    # Run salmon quant (per single-end sample).
    # @note Updated 2022-01-11.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [salmon]="$(koopa::locate_conda_salmon)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_file]=''
        [fastq_tail]='.fastq.gz'
        [gff_file]=''
        [index_dir]='salmon/index'
        [lib_type]='A'
        [output_dir]='salmon/samples'
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bootstraps='*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            '--bootstraps')
                dict[bootstraps]="${2:?}"
                shift 1
                ;;
            '--fastq-file='*)
                dict[fastq_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict[fastq_file]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--gff-file='*)
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict[gff_file]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--threads='*)
                dict[threads]="${1#*=}"
                shift 1
                ;;
            '--threads')
                dict[threads]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--bootstraps' "${dict[bootstraps]}" \
        '--fastq-file' "${dict[fastq_file]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--gff-file' "${dict[gff_file]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}" \
        '--threads' "${dict[threads]}"
    koopa::assert_is_file \
        "${dict[fastq_file]}" \
        "${dict[gff_file]}"
    koopa::assert_is_dir "${dict[index_dir]}"
    dict[fastq_bn]="$(koopa::basename "${dict[fastq_file]}")"
    dict[fastq_bn]="${dict[fastq_bn]/${dict[tail]}/}"
    dict[id]="${dict[fastq_bn]}"
    dict[output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa::h2 "Quantifying '${dict[id]}' into '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[log_file]="${dict[output_dir]}/quant.log"
    # Don't set '--gcBias' here, considered beta for single-end reads.
    # Writing mappings to SAM file blows up disk space too much.
    # > dict[sam_file]="${dict[output_dir]}/output.sam"
    quant_args=(
        "--geneMap=${dict[gff_file]}"
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        "--numBootstraps=${dict[bootstraps]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--seqBias'
        "--threads=${dict[threads]}"
        "--unmatedReads=${dict[fastq]}"
        # > "--writeMappings=${dict[sam_file]}"
    )
    koopa::dl 'Quant args' "${quant_args[*]}"
    "${app[salmon]}" quant "${quant_args[@]}" \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}
