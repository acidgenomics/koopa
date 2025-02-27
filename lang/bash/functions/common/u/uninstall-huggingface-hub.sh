#!/usr/bin/env bash

koopa_uninstall_huggingface_hub() {
    koopa_uninstall_app \
        --name='huggingface-hub' \
        "$@"
}
