#!/usr/bin/env bash

_koopa_file_ext() {
    # """
    # Extract the file extension from input.
    # @note Updated 2020-07-20.
    #
    # Examples:
    # _koopa_file_ext 'hello-world.txt'
    # ## txt
    #
    # _koopa_file_ext 'hello-world.tar.gz'
    # ## gz
    #
    # See also: _koopa_basename_sans_ext
    # """
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        local x
        if _koopa_has_file_ext "$file"
        then
            x="${file##*.}"
        else
            x=''
        fi
        _koopa_print "$x"
    done
    return 0
}
