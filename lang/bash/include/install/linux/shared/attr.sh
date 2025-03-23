#!/usr/bin/env bash

main() {
    # """
    # Install attr.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://savannah.nongnu.org/projects/attr
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/attr.rb
    # """
    local -a conf_args install_args
    local conf_arg
    conf_args=(
       '--disable-debug'
       '--disable-dependency-tracking'
       '--disable-silent-rules'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app --non-gnu-mirror "${install_args[@]}"
    return 0
}
