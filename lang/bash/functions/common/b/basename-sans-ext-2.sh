#!/usr/bin/env bash

koopa_basename_sans_ext_2() {
    # """
    # Extract the file basename prior to any dots in file name.
    # @note Updated 2023-11-30.
    #
    # Examples:
    # koopa_basename_sans_ext_2 'dir/hello-world.tar.gz'
    # ## hello-world
    #
    # See also: koopa_file_ext_2
    # """
    local -A app
    local file
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local str
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="$( \
                koopa_print "$str" \
                | "${app['cut']}" -d '.' -f '1' \
            )"
        fi
        koopa_print "$str"
    done
    return 0
}
