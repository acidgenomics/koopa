#!/usr/bin/env bash
## shellcheck disable=SC2016

if ! _koopa_is_installed python3
then
    _koopa_note "'python3' is not installed. Skipping checks."
    return 0
fi

test_download_ensembl_genome() {
    output_dir="${SHUNIT_TMPDIR}/ensembl"
    mkdir -p "$output_dir"

    download-ensembl-genome \
        --organism="Homo sapiens" \
        --build="GRCh38" \
        --release="99" \
        --output-dir="$output_dir"
    basename="homo-sapiens-grch38-ensembl-99"
    assertTrue "[ -d \"${output_dir}/${basename}\" ]"

    download-ensembl-genome \
        --organism="Mus musculus" \
        --build="GRCm38" \
        --release="99" \
        --output-dir="$output_dir"
    basename="mus-musculus-grcm38-ensembl-99"
    assertTrue "[ -d \"${output_dir}/${basename}\" ]"
}

test_download_flybase_genome() {
    output_dir="${SHUNIT_TMPDIR}/flybase"
    mkdir -p "$output_dir"
    download-flybase-genome \
        --release="FB2019_06" \
        --output-dir="$output_dir"
    basename="drosophila-melanogaster-bdgp6-flybase-fb2019-06"
    assertTrue "[ -d \"${output_dir}/${basename}\" ]"
}

test_download_gencode_genome() {
    output_dir="${SHUNIT_TMPDIR}/gencode"
    mkdir -p "$output_dir"

    download-gencode-genome \
        --organism="Homo sapiens" \
        --build="GRCh38" \
        --release="33" \
        --output-dir="$output_dir"
    basename="homo-sapiens-grch38-gencode-33"
    assertTrue "[ -d \"${output_dir}/${basename}\" ]"

    download-gencode-genome \
        --organism="Mus musculus" \
        --release="M24" \
        --output-dir="$output_dir"
    basename="mus-musculus-grcm38-gencode-m24"
    assertTrue "[ -d \"${output_dir}/${basename}\" ]"
}

test_download_refseq_genome_bin() {
    output_dir="${SHUNIT_TMPDIR}/refseq"
    mkdir -p "$output_dir"
    download-refseq-genome \
        --release="98" \
        --output-dir="$output_dir"
    basename="homo-sapiens-grch38-refseq-98"
    assertTrue "[ -d \"${output_dir}/${basename}\" ]"
}
