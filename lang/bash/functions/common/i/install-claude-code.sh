#!/usr/bin/env bash

# FIXME We need to set against repo here:
# > npm i @anthropic-ai/claude-code

koopa_install_claude_code() {
    koopa_install_app \
        --installer='node-package' \
        --name='claude-code' \
        "$@"
}
