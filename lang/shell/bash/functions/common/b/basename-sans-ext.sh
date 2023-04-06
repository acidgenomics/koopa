#!/usr/bin/env bash

koopa_basename_sans_ext() {
    # """
    # Extract the file basename without extension.
    # @note Updated 2020-06-30.
    #
    # Examples:
    # koopa_basename_sans_ext 'dir/hello-world.txt'
    # ## hello-world
    #
    # koopa_basename_sans_ext 'dir/hello-world.tar.gz'
    # ## hello-world.tar
    #
    # See also: koopa_file_ext
    # """
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        local str
        str="$(koopa_basename "$file")"
        if koopa_has_file_ext "$str"
        then
            str="${str%.*}"
        fi
        koopa_print "$str"
    done
    return 0
}
