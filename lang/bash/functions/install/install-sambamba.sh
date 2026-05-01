#!/usr/bin/env bash

# NOTE 1.0.1 will build on Apple Silicon, but 1.0 (current conda) is broken.

_koopa_install_sambamba() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --installer='conda-package' \
        --name='sambamba' \
        "$@"
}
