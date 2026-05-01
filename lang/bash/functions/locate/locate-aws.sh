#!/usr/bin/env bash

_koopa_locate_aws() {
    _koopa_locate_app \
        --app-name='aws-cli' \
        --bin-name='aws' \
        "$@"
}
