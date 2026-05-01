#!/usr/bin/env bash

_koopa_sra_download_run_info_table() {
    # """
    # Download SRA run info table.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_sra_download_run_info_table --srp-id='SRP049596'
    # # Downloads 'srp049596-run-info-table.csv' to disk.
    # """
    local -A app dict
    _koopa_assert_has_args "$#"
    app['efetch']="$(_koopa_locate_efetch --realpath)"
    app['esearch']="$(_koopa_locate_esearch --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['run_info_file']=''
    dict['srp_id']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict['run_info_file']+=("${1#*=}")
                shift 1
                ;;
            '--file')
                dict['run_info_file']+=("${2:?}")
                shift 2
                ;;
            '--srp-id='*)
                dict['srp_id']="${1#*=}"
                shift 1
                ;;
            '--srp-id')
                dict['srp_id']="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set '--srp-id' "${dict['srp_id']}"
    if [[ -z "${dict['run_info_file']}" ]]
    then
        dict['run_info_file']="$(_koopa_lowercase "${dict['srp_id']}")-\
run-info-table.csv"
    fi
    _koopa_alert "Downloading SRA run info table for '${dict['srp_id']}' \
to '${dict['run_info_file']}'."
    "${app['esearch']}" -db 'sra' -query "${dict['srp_id']}" \
        | "${app['efetch']}" -format 'runinfo' \
        > "${dict['run_info_file']}"
    return 0
}
