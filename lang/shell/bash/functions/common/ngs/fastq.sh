#!/usr/bin/env bash

koopa_convert_fastq_to_fasta() { # {{{1
    # """
    # Convert FASTQ files into FASTA format.
    # @note Updated 2022-03-25.
    #
    # Files must be decompressed.
    #
    # @section Alternate approaches:
    #
    # > seqtk seq -A
    # > bioawk -c fastx '{print ">" $name; print $seq}' "$fastq_file"
    # > cat "$fastq_file" \
    # >     | paste - - - - \
    # >     | awk -v FS="\t" '{print $1"\n"$2}' \
    # >     > "$fasta_file"
    #
    # @examples
    # > koopa_convert_fastq_to_fastq \
    # >     --source-dir='fastq/' \
    # >     --target-dir='fasta/'
    # """
    local app dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [paste]="$(koopa_locate_paste)"
        [sed]="$(koopa_locate_sed)"
        [tr]="$(koopa_locate_tr)"
    )
    declare -A dict=(
        [source_dir]=''
        [target_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    koopa_assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files detected in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    for fastq_file in "${fastq_files[@]}"
    do
        local fasta_file
        fasta_file="${fastq_file%.fastq}.fasta"
        "${app[paste]}" - - - - < "$fastq_file" \
            | "${app[cut]}" -f '1,2' \
            | "${app[sed]}" 's/^@/>/' \
            | "${app[tr]}" '\t' '\n' > "$fasta_file"
    done
    return 0
}

koopa_fastq_detect_quality_score() { # {{{1
    # """
    # Detect quality score format of a FASTQ file.
    # @note Updated 2022-03-25.
    #
    # @seealso
    # - https://onetipperday.blogspot.com/2012/10/
    #     code-snip-to-decide-phred-encoding-of.html
    # - https://bioinformaticsworkbook.org/introduction/
    #     fastqquality-score-encoding.html
    # - https://stackoverflow.com/questions/8151380/
    #   https://github.com/brentp/bio-playground/blob/master/reads-utils/
    #     guess-encoding.py
    #
    # @examples
    # > koopa_fastq_detect_quality_score 'sample_R1.fastq.gz'
    # # Phred+33
    # """
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [head]="$(koopa_locate_head)"
        [od]="$(koopa_locate_od)"
    )
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local str
        # shellcheck disable=SC2016
        str="$( \
            "${app[head]}" -n 1000 \
                <(koopa_decompress --stdout "$file") \
            | "${app[awk]}" '{if(NR%4==0) printf("%s",$0);}' \
            | "${app[od]}" \
                --address-radix='n' \
                --format='u1' \
            | "${app[awk]}" 'BEGIN{min=100;max=0;} \
                {for(i=1;i<=NF;i++) \
                    {if($i>max) max=$i; \
                        if($i<min) min=$i;}}END \
                    {if(max<=74 && min<59) \
                        print "Phred+33"; \
                    else if(max>73 && min>=64) \
                        print "Phred+64"; \
                    else if(min>=59 && min<64 && max>73) \
                        print "Solexa+64"; \
                    else print "Unknown"; \
                }' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_fastq_lanepool() { # {{{1
    # """
    # Pool lane-split FASTQ files.
    # @note Updated 2022-03-25.
    #
    # @examples
    # > koopa_fastq_lanepool --source-dir='fastq/'
    # """
    local app basenames dict fastq_files head i out tail
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
    )
    declare -A dict=(
        [prefix]='lanepool'
        [source_dir]="${PWD:?}"
        [target_dir]="${PWD:?}"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*_L001_*.fastq*' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error if file array is empty.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No lane-split FASTQ files in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    basenames=()
    for i in "${fastq_files[@]}"
    do
        basenames+=("$(koopa_basename "$i")")
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
        i="${dict[target_dir]}/${dict[prefix]}_${i}"
        out+=("$i")
    done
    # Loop across the array indices, similar to 'mapply()' approach in R.
    for i in "${!out[@]}"
    do
        "${app[cat]}" \
            "${dict[source_dir]}/${head[i]}_L00"[1-9]"_${tail[i]}" \
            > "${out[i]}"
    done
    return 0
}

koopa_fastq_number_of_reads() { # {{{1
    # """
    # Return the number of reads per FASTQ file.
    # @note Updated 2022-03-25.
    #
    # @examples
    # > koopa_fastq_number_of_reads 'sample_R1.fastq.gz'
    # # 27584960
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [wc]="$(koopa_locate_wc)"
    )
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        # shellcheck disable=SC2016
        num="$( \
            "${app[wc]}" -l \
                <(koopa_decompress --stdout "$file") \
            | "${app[awk]}" '{print $1/4}' \
        )"
        [[ -n "$num" ]] || return 1
        koopa_print "$num"
    done
    return 0
}
