#!/usr/bin/env bash

koopa::cpu_count() {
    koopa::assert_has_no_args "$#"
    _koopa_cpu_count
}

koopa::group() {
    koopa::assert_has_no_args "$#"
    _koopa_group
}

koopa::group_id() {
    koopa::assert_has_no_args "$#"
    _koopa_group_id
}
