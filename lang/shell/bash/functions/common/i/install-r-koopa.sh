#!/usr/bin/env bash

# FIXME Rework this.
# Need to include: processx, rlang.

koopa_install_r_koopa() {
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'header'
    return 0
}
