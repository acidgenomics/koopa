#!/usr/bin/env bash

koopa_assert_is_ncbi_sra_toolkit_configured() {
    # """
    # Assert that NCBI SRA Toolkit is configured.
    # @note Updated 2023-11-07.
    # """
    local conf_file
    conf_file="${HOME:?}/.ncbi/user-settings.mkfg"
    if [[ ! -f "$conf_file" ]]
    then
        koopa_stop \
            "NCBI SRA Toolkit is not configured at '${conf_file}'." \
            "Run 'vdb-config --interactive' to resolve."
    fi
    return 0
}
