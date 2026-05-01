#!/usr/bin/env bash

_koopa_install_streamlit() {
    _koopa_install_app \
        --installer='python-package' \
        --name='streamlit' \
        "$@"
}
