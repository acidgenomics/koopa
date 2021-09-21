#!/usr/bin/env bash

koopa::linux_install_bcbio_nextgen_genome() { # {{{1
    # """
    # Install a natively supported bcbio-nextgen genome (e.g. hg38).
    # @note Updated 2021-06-11.
    # """
    local bcbio bcbio_args bcbio_dir cores genomes genomes_dir
    local name_fancy str tee tmp_dir
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    koopa::activate_bcbio_nextgen
    genomes=("$@")
    bcbio='bcbio_nextgen.py'
    koopa::assert_is_installed "$bcbio"
    bcbio="$(koopa::which_realpath "$bcbio")"
    bcbio_dir="$(koopa::parent_dir --num=3 "$bcbio")"
    genomes_dir="${bcbio_dir}/genomes"
    str="$(koopa::ngettext "${#genomes[@]}" 'genome' 'genomes')"
    name_fancy="bcbio-nextgen ${str}"
    koopa::install_start "$name_fancy" "$genomes_dir"
    cores="$(koopa::cpu_count)"
    tee="$(koopa::locate_tee)"
    bcbio_args=(
        "--cores=${cores}"
        '--upgrade=skip'
    )
    for genome in "${genomes[@]}"
    do
        bcbio_args+=("--genomes=${genome}")
    done
    koopa::dl \
        'Genomes' "$(koopa::to_string "${genomes[@]}")" \
        'Args' "${bcbio_args[@]}"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        "$bcbio" upgrade "${bcbio_args[@]}"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}
