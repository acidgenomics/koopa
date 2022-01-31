#!/usr/bin/env bash

koopa::assert_is_r_package_installed 'syntactic'

test_camel_case_bin() { # {{{1
    MOCK_INPUT="${SHUNIT_TMPDIR}/foo bar"
    MOCK_OUTPUT="$(koopa::dirname "${MOCK_INPUT}")/fooBar"
    koopa::touch "$MOCK_INPUT"
    assertTrue "[ -f '${MOCK_INPUT}' ]"
    assertFalse "[ -f '${MOCK_OUTPUT}' ]"
    camel-case "$MOCK_INPUT" &>/dev/null
    assertTrue "[ -f '${MOCK_OUTPUT}' ]"
}

test_kebab_case_bin() { # {{{1
    MOCK_INPUT="${SHUNIT_TMPDIR}/foo bar"
    MOCK_OUTPUT="$(koopa::dirname "${MOCK_INPUT}")/foo-bar"
    koopa::touch "$MOCK_INPUT"
    assertTrue "[ -f '${MOCK_INPUT}' ]"
    assertFalse "[ -f '${MOCK_OUTPUT}' ]"
    kebab-case "$MOCK_INPUT" &>/dev/null
    assertTrue "[ -f '${MOCK_OUTPUT}' ]"
}

test_snake_case_bin() { # {{{1
    MOCK_INPUT="${SHUNIT_TMPDIR}/foo bar"
    MOCK_OUTPUT="$(koopa::dirname "${MOCK_INPUT}")/foo_bar"
    koopa::touch "$MOCK_INPUT"
    assertTrue "[ -f '${MOCK_INPUT}' ]"
    assertFalse "[ -f '${MOCK_OUTPUT}' ]"
    snake-case "$MOCK_INPUT" &>/dev/null
    assertTrue "[ -f '${MOCK_OUTPUT}' ]"
}
