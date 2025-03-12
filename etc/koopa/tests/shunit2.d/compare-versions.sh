#!/usr/bin/env bash

test_compare_versions_eq() {
    assertEquals \
        '1.0.0 = 1.0.0' \
        "$( \
            koopa_compare_versions '1.0.0' -eq '1.0.0' \
            && echo 'true' || echo 'false' \
        )" \
        'true'
    assertEquals \
        '1.0.0 = 1.0.1' \
        "$( \
            koopa_compare_versions '1.0.0' -eq '1.0.1' \
            && echo 'true' || echo 'false' \
        )" \
        'false'
}
