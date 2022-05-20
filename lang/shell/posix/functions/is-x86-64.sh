#!/bin/sh

# FIXME Consider moving this to Bash.
koopa_is_x86_64() {
    # """
    # Is the architecture Intel x86 64-bit?
    # @note Updated 2021-11-02.
    #
    # a.k.a. "amd64" (arch2 return).
    # """
    [ "$(koopa_arch)" = 'x86_64' ]
}
