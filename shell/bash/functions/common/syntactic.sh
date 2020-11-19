#!/usr/bin/env bash

koopa::camel_case() { # {{{1
    # """
    # Camel case.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'camel-case' "$@"
    return 0
}

koopa::kebab_case() { # {{{1
    # """
    # Kebab case.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'kebab-case' "$@"
    return 0
}

koopa::snake_case() { # {{{1
    # """
    # Snake case.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'snake-case' "$@"
    return 0
}
