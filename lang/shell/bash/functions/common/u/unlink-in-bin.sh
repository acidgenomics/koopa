#!/usr/bin/env bash

koopa_unlink_in_bin() {
    # """
    # Unlink a program symlinked in koopa 'bin/ directory.
    # @note Updated 2022-08-01.
    #
    # @usage koopa_unlink_in_bin NAME...
    #
    # @examples
    # > koopa_unlink_in_bin 'R' 'Rscript'
    # """
    local bin_link bin_links dict man_links
    koopa_assert_has_args "$#"
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [man_prefix]="$(koopa_man_prefix)"
    )
    bin_links=("$@")
    man_links=()
    for bin_link in "${bin_links[@]}"
    do
        man_links+=("${bin_link}.1")
    done
    __koopa_unlink_in_dir \
        --prefix="${dict[bin_prefix]}" \
        "${bin_links[@]}"
    __koopa_unlink_in_dir \
        --prefix="${dict[man_prefix]}/man1" \
        --quiet \
        "${man_links[@]}"
    return 0
}
