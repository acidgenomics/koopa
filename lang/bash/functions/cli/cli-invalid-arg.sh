#!/usr/bin/env bash

_koopa_cli_invalid_arg() {
    # """
    # CLI invalid argument error message.
    # @note Updated 2022-04-17.
    # """
    if [[ "$#" -eq 0 ]]
    then
        _koopa_stop "Missing required argument. \
Check autocompletion of supported arguments with <TAB>."
    else
        _koopa_stop "Invalid and/or incomplete argument: '${*}'.\n\
Check autocompletion of supported arguments with <TAB>."
    fi
}
