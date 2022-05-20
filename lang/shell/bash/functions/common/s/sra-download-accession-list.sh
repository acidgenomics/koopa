#!/usr/bin/env bash

koopa_sra_download_accession_list() {
    # """
    # Download SRA accession list.
    # @note Updated 2022-02-11.
    #
    # @examples
    # > koopa_sra_download_accession_list --srp-id='SRP049596'
    # # Downloads 'srp049596-accession-list.txt' to disk.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [efetch]="$(koopa_locate_efetch)"
        [esearch]="$(koopa_locate_esearch)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [acc_file]=''
        [srp_id]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[acc_file]+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict[acc_file]+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict[srp_id]="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict[srp_id]="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[acc_file]}" ]]
    then
        dict[acc_file]="$(koopa_lowercase "${dict[srp_id]}")-\
accession-list.txt"
    fi
    koopa_alert "Downloading SRA accession list for '${dict[srp_id]}' \
to '${dict[acc_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        | "${app[sed]}" '1d' \
        | "${app[cut]}" -d ',' -f '1' \
        > "${dict[acc_file]}"
    return 0
}
