#!/usr/bin/env bash

koopa_has_standard_umask() {
    # """
    # Is the system running with a standard or more restrictive umask"
    # @note Updated 2025-02-18.
    # """
    # Ensure scripts create files with expected permissions. This is
    # standard on Debian and macOS. Systems that change from this default to a
    # more restrictive setting (i.e. 0077) can break install scripts.
    # """
    local -A dict
    dict['default_umask']="$(umask)"
    case "${dict['default_umask']}" in
        '0002' | '002' | \
        '0022' | '022')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
