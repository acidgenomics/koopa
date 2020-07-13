#!/usr/bin/env bash

koopa::tx2gene_from_ensembl_fasta() {
    local count fasta_file fasta_file_bn output_file output_file_bn
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed awk cut grep gunzip sed tr
    fasta_file="${1:?}"
    koopa::assert_is_file "$fasta_file"
    koopa::assert_is_matching_fixed "$fasta_file" '.cdna.all.fa.gz'
    output_file="${2:-tx2gene.csv}"
    koopa::assert_is_not_file "$output_file"
    fasta_file_bn="$(basename "$fasta_file")"
    output_file_bn="$(basename "$output_file")"
    koopa::h1 "Generating \"${output_file_bn}\" from \"${fasta_file_bn}\"."
    gunzip -c "$fasta_file" \
        | grep '>' \
        | cut -d ' ' -f1,4 \
        | awk '!a[$0]++' \
        | tr -d '>' \
        | sed -E 's/ [a-z]+:/,/g' \
        > "$output_file"
    count="$(koopa::line_count "$output_file")"
    koopa::info "${count} transcripts detected."
    return 0
}

koopa::tx2gene_from_flybase_fasta() {
    local count fasta_file fasta_file_bn output_file output_file_bn
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed awk cut grep gunzip sed tr
    fasta_file="${1:?}"
    koopa::assert_is_file "$fasta_file"
    output_file="${2:-tx2gene.csv}"
    koopa::assert_is_matching_fixed "$fasta_file" 'dmel-transcriptome-'
    koopa::assert_is_not_file "$output_file"
    fasta_file_bn="$(basename "$fasta_file")"
    output_file_bn="$(basename "$output_file")"
    koopa::h1 "Generating \"${output_file_bn}\" from \"${fasta_file_bn}\"."
    gunzip -c "$fasta_file" \
        | grep '>' \
        | cut -d ' ' -f1,9 \
        | tr -d '>' \
        | sed -E 's/ parent=(FBgn[0-9]{7}).*/,\1/g' \
        | awk '!a[$0]++' \
        > "$output_file"
    count="$(koopa::line_count "$output_file")"
    koopa::info "${count} transcripts detected."
    return 0
}

koopa::tx2gene_from_gencode_fasta() {
    local fasta_file fasta_file_bn output_file output_file_bn
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed awk cut grep gunzip sed tr
    fasta_file="$1"
    koopa::assert_is_file "$fasta_file"
    output_file="${2:-tx2gene.csv}"
    koopa::assert_is_matching_fixed "$fasta_file" '.transcripts.fa.gz'
    koopa::assert_is_not_file "$output_file"
    fasta_file_bn="$(basename "$fasta_file")"
    output_file_bn="$(basename "$output_file")"
    koopa::h1 "Generating \"${output_file_bn}\" from \"${fasta_file_bn}\"."
    gunzip -c "$fasta_file" \
        | grep '>' \
        | cut -d '|' -f1,2 \
        | awk '!a[$0]++' \
        | tr -d '>' \
        | sed 's/|/,/g' \
        > "$output_file"
    count="$(koopa::line_count "$output_file")"
    koopa::info "${count} transcripts detected."
    return 0
}

koopa::tx2gene_from_wormbase_fasta() {
    local count fasta_file fasta_file_bn output_file output_file_bn
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed awk cut grep gunzip sed tr
    fasta_file="${1:?}"
    koopa::assert_is_file "$fasta_file"
    output_file="${2:-tx2gene.csv}"
    koopa::assert_is_matching_fixed "$fasta_file" '.mRNA_transcripts.fa.gz'
    koopa::assert_is_not_file "$output_file"
    fasta_file_bn="$(basename "$fasta_file")"
    output_file_bn="$(basename "$output_file")"
    koopa::h1 "Generating \"${output_file_bn}\" from \"${fasta_file_bn}\"."
    gunzip -c "$fasta_file" \
        | grep '>' \
        | cut -d ' ' -f1,2 \
        | awk '!a[$0]++' \
        | tr -d '>' \
        | sed -E 's/ [a-z]+=/,/g' \
        > "$output_file"
    count="$(koopa::line_count "$output_file")"
    koopa::info "${count} transcripts detected."
    return 0
}

