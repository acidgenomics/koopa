#!/bin/sh

_koopa_rust_prefix() {
    # """
    # Rust install prefix.
    # @note Updated 2021-05-25.
    # """
    _koopa_print "$(koopa_opt_prefix)/rust"
    return 0
}
