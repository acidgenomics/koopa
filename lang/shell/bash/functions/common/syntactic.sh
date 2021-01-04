#!/usr/bin/env bash

koopa::camel_case() { # {{{1
    # """
    # Camel case.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'camelCase' "$@"
    return 0
}

koopa::kebab_case() { # {{{1
    # """
    # Kebab case.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'kebabCase' "$@"
    return 0
}

koopa::snake_case() { # {{{1
    # """
    # Snake case.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'snakeCase' "$@"
    return 0
}
