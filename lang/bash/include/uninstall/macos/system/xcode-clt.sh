#!/usr/bin/env bash

main() {
    # """
    # Uninstall Xcode CLT.
    # @note Updated 2021-10-30.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/308943
    # """
    local -A dict
    dict['prefix']='/Library/Developer/CommandLineTools'
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_rm --sudo "${dict['prefix']}"
    return 0
}
