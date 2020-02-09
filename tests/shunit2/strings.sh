#!/usr/bin/env bash

test_gsub() {
    assertEquals \
        "$(_koopa_gsub "aaa-aaa-bbb-bbb" "bbb" "ccc")" \
        "aaa-aaa-ccc-ccc"
}

test_snake_case() {
    assertEquals \
        "$(_koopa_snake_case "hello world")" \
        "hello_world"
}
