#!/usr/bin/env bash

test_compare_versions() {
    (koopa_compare_versions '1.0.0' -eq '1.0.0')
    assertTrue '1.0.0 = 1.0.0' "$?"
    (koopa_compare_versions '1.0.0' -eq '1.0.1')
    assertFalse '1.0.0 = 1.0.1' "$?"
}
