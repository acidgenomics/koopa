#!/usr/bin/env bash

test_gsub() {
    assertEquals \
        "$(\
            koopa_gsub \
                --pattern='bbb' \
                --replacement='ccc' \
                'aaa-aaa-bbb-bbb' \
        )" \
        'aaa-aaa-ccc-ccc'
}

test_kebab_case() {
    assertEquals \
        "$(koopa_kebab_case 'hello world')" \
        'hello-world'
}

test_sanitize_version() {
    assertEquals \
        "$(koopa_sanitize_version '2.7.1p83')" \
        '2.7.1'
}

test_snake_case() {
    assertEquals \
        "$(koopa_snake_case 'hello world')" \
        'hello_world'
}

test_strip_left() {
    assertEquals \
        "$( \
            koopa_strip_left \
                --pattern='The ' \
                'The Quick Brown Fox' \
        )" \
        'Quick Brown Fox'
}

test_strip_right() {
    assertEquals \
        "$( \
            koopa_strip_right \
                --pattern=' Fox' \
                'The Quick Brown Fox' \
        )" \
        'The Quick Brown'
}

_test_strip_trailing_slash() {
    assertEquals \
        "$(koopa_strip_trailing_slash 'https://acidgenomics.com/')" \
        'https://acidgenomics.com'
}

test_sub() {
    assertEquals \
        "$( \
            koopa_sub \
                --pattern='bbb' \
                --replacement='ccc' \
                'aaa-aaa-bbb-bbb' \
        )" \
        'aaa-aaa-ccc-bbb'
}

test_trim_ws() {
    assertEquals \
        "$(koopa_trim_ws '    Hello,  World    ')" \
        'Hello,  World'
}
