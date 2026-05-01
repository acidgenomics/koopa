#!/usr/bin/env bash

_koopa_basename_sans_ext() {
    # """
    # Extract the file basename without extension.
    # @note Updated 2023-11-30.
    #
    # Examples:
    # _koopa_basename_sans_ext 'dir/hello-world.txt'
    # ## hello-world
    #
    # _koopa_basename_sans_ext 'dir/hello-world.tar.gz'
    # ## hello-world.tar
    #
    # See also: _koopa_file_ext
    # """
    local file
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for file in "$@"
    do
        local str
        str="$(_koopa_basename "$file")"
        if _koopa_has_file_ext "$str"
        then
            str="${str%.*}"
        fi
        _koopa_print "$str"
    done
    return 0
}
