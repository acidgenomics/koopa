#!/usr/bin/env bash

koopa_cli_nested_runner() {
    # """
    # Nested CLI runner function.
    # @note Updated 2022-02-16.
    #
    # Used to standardize handoff handling of 'configure', 'install',
    # 'uninstall', and 'update' commands.
    # """
    local dict
    declare -A dict=(
        [runner]="${1:?}"
        [key]="${2:-}"
    )
    case "${dict[key]}" in
        '')
            koopa_cli_invalid_arg
            ;;
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man/man1/${dict[runner]}.1"
            ;;
        '-'*)
            koopa_cli_invalid_arg "$@"
            ;;
        *)
            shift 2
            ;;
    esac
    koopa_print "${dict[runner]}-${dict[key]}" "$@"
    return 0
}
