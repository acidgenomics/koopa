#!/usr/bin/env bash

test_r_paste_to_vector() { # {{{1
    assertEquals \
        "$(koopa::r_paste_to_vector 'aaa' 'bbb')" \
        'c("aaa", "bbb")'
}
