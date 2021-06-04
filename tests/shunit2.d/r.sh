#!/usr/bin/env bash

test_array_to_r_vector() { # {{{1
    assertEquals \
        "$(koopa::array_to_r_vector 'aaa' 'bbb')" \
        'c("aaa", "bbb")'
}
