#!/usr/bin/env bash

koopa_file_ext() {
    # """
    # Extract the file extension from input.
    # @note Updated 2020-07-20.
    #
    # Examples:
    # koopa_file_ext 'hello-world.txt'
    # ## txt
    #
    # koopa_file_ext 'hello-world.tar.gz'
    # ## gz
    #
    # See also: koopa_basename_sans_ext
    # """
    local file x
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        if koopa_has_file_ext "$file"
        then
            x="${file##*.}"
        else
            x=''
        fi
        koopa_print "$x"
    done
    return 0
}
