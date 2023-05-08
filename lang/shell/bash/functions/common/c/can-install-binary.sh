#!/usr/bin/env bash

koopa_can_install_binary() {
    # """
    # Can the current user install and/or push a koopa binary?
    # @note Updated 2023-05-08.
    # 
    # Currently requires access to our private S3 bucket.
    # """
    local -A dict
    dict['config']="${HOME:?}/.aws/config"
    dict['credentials']="${HOME:?}/.aws/credentials"
    [[ -f "${dict['config']}" ]] || return 1
    [[ -f "${dict['credentials']}" ]] || return 1
    koopa_file_detect_fixed \
        --file="${dict['config']}" \
        --pattern='acidgenomics' \
        || return 1
    koopa_file_detect_fixed \
        --file="${dict['credentials']}" \
        --pattern='acidgenomics' \
        || return 1
    return 0
}
