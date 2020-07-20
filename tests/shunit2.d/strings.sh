#!/usr/bin/env bash

test_gsub() { # {{{1
    assertEquals \
        "$(koopa::gsub 'bbb' 'ccc' 'aaa-aaa-bbb-bbb')" \
        'aaa-aaa-ccc-ccc'
}

test_sanitize_version() { # {{{1
    assertEquals \
        "$(koopa::sanitize_version '2.7.1p83')" \
        '2.7.1'
}

test_snake_case() { # {{{1
    assertEquals \
        "$(koopa::snake_case 'hello world')" \
        'hello_world'
}

test_strip_left() { # {{{1
    assertEquals \
        "$(koopa::strip_left 'The ' 'The Quick Brown Fox')" \
        'Quick Brown Fox'
}

test_strip_right() { # {{{1
    assertEquals \
        "$(koopa::strip_right ' Fox' 'The Quick Brown Fox')" \
        'The Quick Brown'
}

_test_strip_trailing_slash() { # {{{1
    assertEquals \
        "$(koopa::strip_trailing_slash 'https://acidgenomics.com/')" \
        'https://acidgenomics.com'
}

test_sub() { # {{{1
    assertEquals \
        "$(koopa::sub 'bbb' 'ccc' 'aaa-aaa-bbb-bbb')" \
        'aaa-aaa-ccc-bbb'
}

test_trim_ws() { # {{{1
    assertEquals \
        "$(koopa::trim_ws '    Hello,  World    ')" \
        'Hello,  World'
}
