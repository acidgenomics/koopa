#!/usr/bin/env bash

koopa_has_standard_umask() {
    # """
    # Is the system running with a standard or more restrictive umask"
    # @note Updated 2024-06-27.
    # """
    # Ensure scripts create files with expected permissions. This is
    # standard on Debian and macOS. Systems that change from this default to a
    # more restrictive setting (i.e. 0077) can break install scripts.
    # """
    case "$(umask)" in
        '0002' | '002' | \
        '0022' | '022')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
