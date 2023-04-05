#!/usr/bin/env bash

koopa_file_ext_2() {
    # """
    # Extract the file extension after any dots in the file name.
    # @note Updated 2023-04-05.
    #
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # koopa_file_ext_2 'hello-world.tar.gz'
    # ## tar.gz
    #
    # See also: koopa_basename_sans_ext_2
    # """
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        if koopa_has_file_ext "$file"
        then
            str="$( \
                koopa_print "$file" \
                | "${app['cut']}" -d '.' -f '2-' \
            )"
        else
            str=''
        fi
        koopa_print "$str"
    done
    return 0
}
