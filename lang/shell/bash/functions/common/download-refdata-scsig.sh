#!/usr/bin/env bash

koopa_download_refdata_scsig() {
    # """
    # Download MSigDB SCSig reference data (now archived).
    # @note Updated 2021-12-09.
    #
    # @seealso
    # - https://www.gsea-msigdb.org/gsea/msigdb/supplementary_genesets.jsp
    # """
    local basename basenames dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [base_url]='http://software.broadinstitute.org/gsea/msigdb/supplemental'
        [name_fancy]='MSigDB SCSig'
        [refdata_prefix]="$(koopa_refdata_prefix)"
        [version]='1.0.1'
    )
    dict[prefix]="${dict[refdata_prefix]}/scsig/${dict[version]}"
    koopa_assert_is_not_dir "${dict[prefix]}"
    koopa_alert "Downloading ${dict[name_fancy]} ${dict[version]} \
to ${dict[prefix]}."
    koopa_mkdir "${dict[prefix]}"
    basenames=(
        "scsig.all.v${dict[version]}.entrez.gmt"
        "scsig.all.v${dict[version]}.symbols.gmt"
        "scsig.v${dict[version]}.metadata.txt"
        "scsig.v${dict[version]}.metadata.xls"
    )
    for basename in "${basenames[@]}"
    do
        koopa_download \
            "${dict[base_url]}/${basename}" \
            "${dict[prefix]}/${basename]}"
    done
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_alert_success "Download of ${dict[name_fancy]} to \
${dict[prefix]} was successful."
    return 0
}
