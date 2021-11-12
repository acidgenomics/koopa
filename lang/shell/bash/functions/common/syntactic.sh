#!/usr/bin/env bash

# FIXME These need options to also rename the extension to lowercase.

koopa::camel_case() { # {{{1
    # """
    # Camel case.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliCamelCase' "$@"
    return 0
}

koopa::kebab_case() { # {{{1
    # """
    # Kebab case.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliKebabCase' "$@"
    return 0
}

koopa::snake_case() { # {{{1
    # """
    # Snake case.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliSnakeCase' "$@"
    return 0
}
