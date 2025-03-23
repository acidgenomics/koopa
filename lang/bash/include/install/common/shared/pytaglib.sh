#!/usr/bin/env bash

# FIXME This isn't compatible with TagLib v2.0 release.

main() {
    koopa_activate_app 'taglib'
    koopa_install_python_package \
        --extra-package='tqdm' \
        --no-binary
    return 0
}
