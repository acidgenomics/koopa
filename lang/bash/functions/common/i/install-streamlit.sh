#!/usr/bin/env bash

koopa_install_streamlit() {
    koopa_install_app \
        --installer='python-package' \
        --name='streamlit' \
        "$@"
}
