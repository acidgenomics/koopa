#!/usr/bin/env bash

# FIXME Need to automatically handle man files here too.

# Some examples:
# - coreutils: share/man/man1

# FIXME See if we can match file here:
# share/man/man1/XXX.1

koopa_link_in_bin() {
    # """
    # Link a program in koopa 'bin/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage
    # > koopa_link_in_bin \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_bin \
    # >     '/usr/local/bin/emacs' 'emacs' \
    # >     '/usr/local/bin/vim' 'vim'
    # """
    local bin_files bin_links dict
    koopa_assert_has_args "$#"
    bin_files=()
    bin_links=()
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [man_prefix]="$(koopa_man_prefix)"
    )
    while [[ "$#" -ge 2 ]]
    do
        bin_files+=("${1:?}")
        bin_links+=("${2:?}")
        shift 2
    done
    for i in "${!bin_files[@]}"
    do
        local dict2
        declare -A dict2
        dict2[bin_file]="${bin_files[$i]}"
        dict2[bin_link]="${bin_links[$i]}"
        dict2[bin_file_bn]="$(koopa_basename "${dict2[bin_file]}")"
        dict2[parent_dir]="$(koopa_parent_dir --num=2 "${dict2[bin_file]}")"
        dict2[man1_file]="${dict2[parent_dir]}/share/man/\
man1/${dict2[bin_file_bn]}.1"
        dict2[man1_link]="${dict2[bin_link]}.1"
        __koopa_link_in_dir \
            --prefix="${dict[bin_prefix]}" \
            "${dict2[bin_file]}" "${dict2[bin_link]}"
        __koopa_link_in_dir \
            --prefix="${dict[man_prefix]}/man1" \
            "${dict2[man1_file]}" "${dict2[man1_link]}"
    done
    return 0
}
