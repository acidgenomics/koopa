#!/usr/bin/env bash

# FIXME This doesn't work as expected with absolute path:
# /opt/koopa/bin/efetch --version
# ERROR:  Unable to find '/opt/koopa/bin/ecommon.sh' file

koopa_install_entrez_direct() {
    koopa_assert_is_not_arm64
    koopa_install_app \
        --installer='conda-package' \
        --name='entrez-direct' \
        "$@"
}
