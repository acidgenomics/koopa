#!/usr/bin/env bash

test_r_paste_to_vector() {
    assertEquals \
        "$(koopa_r_paste_to_vector 'aaa' 'bbb')" \
        'c("aaa", "bbb")'
}
