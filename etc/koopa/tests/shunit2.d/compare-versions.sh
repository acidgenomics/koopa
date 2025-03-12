#!/usr/bin/env bash

test_compare_versions_eq() {
    assertTrue \
        "$(koopa_compare_versions '1.0.0' -eq '1.0.0')"
    assertFalse \
        "$(koopa_compare_versions '1.0.0' -eq '1.0.1')"
}
