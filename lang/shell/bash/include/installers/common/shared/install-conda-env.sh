#!/usr/bin/env bash

main() {
    # """
    # Install a conda environment as an application.
    # @note Updated 2022-06-20.
    # """
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="$(koopa_init_dir "${dict[prefix]}/libexec")"
    case "${dict[name]}" in
        'entrez-direct')
            bin_names=(
                'accn-at-a-time'
                'align-columns'
                'amino-acid-composition'
                'archive-pubmed'
                'asn2xml'
                'between-two-genes'
                'blst2tkns'
                'csv2xml'
                'disambiguate-nucleotides'
                'download-ncbi-data'
                'download-ncbi-software'
                'download-pubmed'
                'download-sequence'
                'ecommon.sh'
                'edirect.py'
                'efetch'
                'efilter'
                'einfo'
                'elink'
                'epost'
                'esample'
                'esearch'
                'esummary'
                'exclude-uid-lists'
                'expand-current'
                'fetch-pubmed'
                'filter-columns'
                'filter-stop-words'
                'find-in-gene'
                'fuse-ranges'
                'fuse-segments'
                'gbf2xml'
                'gene2range'
                'hgvs2spdi'
                'intersect-uid-lists'
                'join-into-groups-of'
                'json2xml'
                'nquire'
                'phrase-search'
                'print-columns'
                'rchive'
                'reorder-columns'
                'run-ncbi-converter'
                'skip-if-file-exists'
                'snp2hgvs'
                'snp2tbl'
                'sort-table'
                'sort-uniq-count'
                'sort-uniq-count-rank'
                'spdi2tbl'
                'split-at-intron'
                'stream-pubmed'
                'tbl2prod'
                'tbl2xml'
                'test-edirect'
                'test-eutils'
                'test-pubmed-index'
                'transmute'
                'uniq-table'
                'word-at-a-time'
                'xml2fsa'
                'xml2json'
                'xml2tbl'
                'xtract'
            )
            ;;
        'ghostscript')
            bin_names=('gs')
            ;;
        'star')
            # Case sensitive.
            bin_names=('STAR')
            ;;
        *)
            bin_names=("${dict[name]}")
            ;;
    esac
    koopa_conda_create_env \
        --prefix="${dict[libexec]}" \
        "${dict[name]}==${dict[version]}"
    for bin_name in "${bin_names[@]}"
    do
        koopa_ln \
            "${dict[libexec]}/bin/${bin_name}" \
            "${dict[prefix]}/bin/${bin_name}"
    done
    return 0
}
