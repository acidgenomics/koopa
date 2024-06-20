#!/usr/bin/env bash

koopa_has_private_access() {
    # """
    # Does the current user have access to our private S3 bucket?
    # @note Updated 2024-06-20.
    # """
    local file
    file="${HOME}/.aws/credentials"
    [[ -f "$file" ]] || return 1
    koopa_file_detect_regex \
        --file="$file" \
        --pattern='^[acidgenomics]$'
}
