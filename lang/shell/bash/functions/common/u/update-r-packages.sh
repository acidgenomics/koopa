#!/usr/bin/env bash

koopa_update_r_packages() {
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliUpdateRPackages'
    return 0
}
