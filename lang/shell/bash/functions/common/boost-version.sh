#!/usr/bin/env bash

koopa_boost_version() {
    # """
    # Boost (libboost) version.
    # @note Updated 2022-02-25.
    #
    # Extract the Boost library version using GCC preprocessing. This approach
    # is nice because it doesn't hardcode to a specific file path.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3708706/
    # - https://stackoverflow.com/questions/4518584/
    # """
    local app dict gcc_args
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bc]="$(koopa_locate_bc)"
        [gcc]="$(koopa_locate_gcc)"
    )
    declare -A dict
    gcc_args=()
    if koopa_is_macos
    then
        dict[brew_prefix]="$(koopa_homebrew_prefix)"
        gcc_args+=("-I${dict[brew_prefix]}/opt/boost/include")
    fi
    gcc_args+=(
        '-x' 'c++'
        '-E' '-'
    )
    dict[version]="$( \
        koopa_print '#include <boost/version.hpp>\nBOOST_VERSION' \
        | "${app[gcc]}" "${gcc_args[@]}" \
        | koopa_grep --pattern='^[0-9]+$' --regex \
    )"
    [[ -n "${dict[version]}" ]] || return 1
    # Convert '107500' to '1.75.0', for example.
    dict[major]="$(koopa_print "${dict[version]} / 100000" | "${app[bc]}")"
    dict[minor]="$(koopa_print "${dict[version]} / 100 % 1000" | "${app[bc]}")"
    dict[patch]="$(koopa_print "${dict[version]} % 100" | "${app[bc]}")"
    koopa_print "${dict[major]}.${dict[minor]}.${dict[patch]}"
    return 0
}
