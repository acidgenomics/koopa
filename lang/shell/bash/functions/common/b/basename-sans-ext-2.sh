#!/usr/bin/env bash

koopa_basename_sans_ext_2() {
    # """
    # Extract the file basename prior to any dots in file name.
    # @note Updated 2022-05-16.
    #
    # Examples:
    # koopa_basename_sans_ext_2 'dir/hello-world.tar.gz'
    # ## hello-world
    #
    # See also: koopa_file_ext_2
    # """
    local app file str
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    for file in "$@"
    do
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="$( \
                koopa_print "$str" \
                | "${app[cut]}" -d '.' -f '1' \
            )"
        fi
        koopa_print "$str"
    done
    return 0
}
