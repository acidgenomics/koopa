#!/usr/bin/env bash

test_gsub() {
    assertEquals \
        "$(koopa::gsub 'bbb' 'ccc' 'aaa-aaa-bbb-bbb')" \
        'aaa-aaa-ccc-ccc'
}

test_snake_case() {
    assertEquals \
        "$(koopa::snake_case 'hello world')" \
        'hello_world'
}

test_strip_left() {
    assertEquals \
        "$(koopa::strip_left 'The ' 'The Quick Brown Fox')" \
        'Quick Brown Fox'
}

test_strip_right() {
    assertEquals \
        "$(koopa::strip_right ' Fox' 'The Quick Brown Fox')" \
        'The Quick Brown'
}

_test_strip_trailing_slash() {
    assertEquals \
        "$(koopa::strip_trailing_slash 'https://acidgenomics.com/')" \
        'https://acidgenomics.com'
}

test_sub() {
    assertEquals \
        "$(koopa::sub 'bbb' 'ccc' 'aaa-aaa-bbb-bbb')" \
        'aaa-aaa-ccc-bbb'
}

test_trim_ws() {
    assertEquals \
        "$(koopa::trim_ws '    Hello,  World    ')" \
        'Hello,  World'
}
