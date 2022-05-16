#!/bin/sh

koopa_is_linux() {
    # """
    # Is the current operating system Linux?
    # @note Updated 2020-02-05.
    # """
    [ "$(uname -s)" = 'Linux' ]
}
