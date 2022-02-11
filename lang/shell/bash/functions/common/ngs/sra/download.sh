#!/usr/bin/env bash

koopa::sra_download_accession_list() { # {{{1
    # """
    # Download SRA accession list.
    # @note Updated 2022-02-11.
    #
    # @examples
    # > koopa::sra_download_accession_list --srp-id='SRP049596'
    # # Downloads 'srp049596-accession-list.txt' to disk.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [efetch]="$(koopa::locate_efetch)"
        [esearch]="$(koopa::locate_esearch)"
        [sed]="$(koopa::locate_sed)"
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
            # Invalid ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[acc_file]}" ]]
    then
        dict[acc_file]="$(koopa::lowercase "${dict[srp_id]}")-\
accession-list.txt"
    fi
    koopa::alert "Downloading SRA accession list for '${dict[srp_id]}' \
to '${dict[acc_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        | "${app[sed]}" '1d' \
        | "${app[cut]}" -d ',' -f 1 \
        > "${dict[acc_file]}"
    return 0
}

koopa::sra_download_run_info_table() { # {{{1
    # """
    # Download SRA run info table.
    # @note Updated 2022-02-11.
    #
    # @examples
    # > koopa::sra_download_run_info_table --srp-id='SRP049596'
    # # Downloads 'srp049596-run-info-table.csv' to disk.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [efetch]="$(koopa::locate_efetch)"
        [esearch]="$(koopa::locate_esearch)"
    )
    declare -A dict=(
        [run_info_file]=''
        [srp_id]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[run_info_file]+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict[run_info_file]+=("${2:?}")
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
            # Invalid ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--srp-id' "${dict[srp_id]}"
    if [[ -z "${dict[run_info_file]}" ]]
    then
        dict[run_info_file]="$(koopa::lowercase "${dict[srp_id]}")-\
run-info-table.csv"
    fi
    koopa::alert "Downloading SRA run info table for '${dict[srp_id]}' \
to '${dict[run_info_file]}'."
    "${app[esearch]}" -db 'sra' -query "${dict[srp_id]}" \
        | "${app[efetch]}" -format 'runinfo' \
        > "${dict[run_info_file]}"
    return 0
}
