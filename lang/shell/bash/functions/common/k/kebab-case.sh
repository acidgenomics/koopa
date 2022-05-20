#!/usr/bin/env bash

koopa_kebab_case() {
    # """
    # Kebab case.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliKebabCase' "$@"
}
