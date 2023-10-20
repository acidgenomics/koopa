#!/usr/bin/env bash

koopa_fasta_has_alt_contigs() {
    # """
    # Does the FASTA file contain ALT contigs?
    # @note Updated 2023-10-20.
    #
    # @section Expected failures:
    # ftp://ftp.ncbi.nlm.nih.gov/genomes/all/annotation_releases/9606/110/
    # GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz
    # rg -i ' ALT_' 'GCF_000001405.40_GRCh38.p14_genomic.fna'
    # rg -i ' alternate locus group ' 'GCF_000001405.40_GRCh38.p14_genomic.fna'
    #
    # ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/
    # GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/
    # GCA_000001405.15_GRCh38_full_analysis_set.fna.gz
    # > rg '^[^\s]+_alt\s' GCA_000001405.15_GRCh38_full_analysis_set.fna
    # > rg ' rl:alt-scaffold ' GCA_000001405.15_GRCh38_full_analysis_set.fna
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     heterogeneity/chromhacks.py#L75
    # - https://lh3.github.io/2017/11/13/which-human-reference-genome-to-use
    # - https://googlegenomics.readthedocs.io/en/latest/use_cases/
    #     discover_public_data/reference_genomes.html#verily-s-grch38
    # - https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/
    #     GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/
    #
    # Links related to STAR indexing:
    # - https://github.com/alexdobin/STAR/issues/39
    # - https://github.com/chapmanb/cloudbiolinux/tree/master/
    #     ggd-recipes/hg38-noalt
    # - https://groups.google.com/g/rna-star/c/mo1QZ-7QPkc
    # - https://groups.google.com/g/rna-star/c/rVzRipcCLIA/m/6e2d3pBkx-wJ
    # """
    local -A bool dict
    koopa_assert_has_args_eq "$#" 1
    bool['tmp_file']=0
    dict['file']="${1:?}"
    dict['status']=1
    koopa_assert_is_file "${dict['file']}"
    if koopa_is_compressed_file "${dict['file']}"
    then
        bool['tmp_file']=1
        dict['tmp_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress "${dict['file']}" "${dict['tmp_file']}"
        dict['file']="${dict['tmp_file']}"
    fi
    if koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern=' ALT_' \
    || koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern=' alternate locus group ' \
    || koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern=' rl:alt-scaffold '
    then
        dict['status']=0
    fi
    if [[ "${bool['tmp_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['file']}"
    fi
    return "${dict['status']}"
}
