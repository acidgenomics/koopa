#!/usr/bin/env bash

koopa_locate_aws() {
    koopa_locate_app \
        --app-name='aws-cli' \
        --bin-name='aws' \
        "$@"
}
