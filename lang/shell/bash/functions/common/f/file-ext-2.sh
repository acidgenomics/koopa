#!/usr/bin/env bash

koopa_file_ext_2() {
    # """
    # Extract the file extension after any dots in the file name.
    # @note Updated 2021-11-04.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # koopa_file_ext_2 'hello-world.tar.gz'
    # ## tar.gz
    #
    # See also: koopa_basename_sans_ext_2
    # """
    local app file x
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="$( \
                koopa_print "$file" \
                | "${app[cut]}" -d '.' -f '2-' \
            )"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}
