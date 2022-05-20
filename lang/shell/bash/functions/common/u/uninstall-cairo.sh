#!/usr/bin/env bash

koopa_uninstall_cairo() {
    koopa_uninstall_app \
        --name-fancy='Cairo' \
        --name='cairo' \
        "$@"
}
