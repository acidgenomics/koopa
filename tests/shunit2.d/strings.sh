#!/usr/bin/env bash

test_gsub() {
    assertEquals \
        "$(_koopa_gsub "bbb" "ccc" "aaa-aaa-bbb-bbb")" \
        "aaa-aaa-ccc-ccc"
}

test_snake_case() {
    assertEquals \
        "$(_koopa_snake_case "hello world")" \
        "hello_world"
}

test_strip_left() {
    assertEquals \
        "$(_koopa_strip_left "The " "The Quick Brown Fox")" \
        "Quick Brown Fox"
}

test_strip_right() {
    assertEquals \
        "$(_koopa_strip_right " Fox" "The Quick Brown Fox")" \
        "The Quick Brown"
}

_test_strip_trailing_slash() {
    assertEquals \
        "$(_koopa_strip_trailing_slash "https://acidgenomics.com/")" \
        "https://acidgenomics.com"
}

test_sub() {
    assertEquals \
        "$(_koopa_sub "bbb" "ccc" "aaa-aaa-bbb-bbb")" \
        "aaa-aaa-ccc-bbb"
}

test_trim_ws() {
    assertEquals \
        "$(_koopa_trim_ws "    Hello,  World    ")" \
        "Hello,  World"
}
