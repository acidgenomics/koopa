#!/usr/bin/env bash

koopa_ruby_api_version() {
    # """
    # Ruby API version.
    # @note Updated 2022-03-18.
    #
    # @section Gem installation path:
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [ruby]="${1:-}"
    )
    [[ -z "${app[ruby]}" ]] && app[ruby]="$(koopa_locate_ruby)"
    str="$("${app[ruby]}" -e 'print Gem.ruby_api_version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
