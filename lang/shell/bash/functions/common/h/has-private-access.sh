#!/usr/bin/env bash

koopa_has_private_acccess() {
    # """
    # Does the current user have access to our private S3 bucket?
    # @note Updated 2023-03-14.
    # """
    local file
    file="${HOME}/.aws/credentials"
    [[ -f "$file" ]] || return 1
    koopa_file_detect_fixed \
        --file="$file" \
        --pattern='[acidgenomics]'
}
