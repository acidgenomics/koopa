#!/usr/bin/env bash

koopa_fastq_detect_quality_score() {
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
