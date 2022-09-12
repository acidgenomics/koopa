#!/usr/bin/env bash

# FIXME This currently crashes on Debian when passing to 'env' call...
# Need to rethink our approach.

# Running mktexlsr. This may take some time... done.
#Processing triggers for install-info (6.8-4build1) ...
#
#[1]+  Stopped                 ( koopa_cd "${dict['tmp_dir']}"; export KOOPA_INSTALL_NAME="${dict['name']}"; export KOOPA_INSTALL_PREFIX="${dict['prefix']}"; export KOOPA_INSTALL_VERSION="${dict['version']}"; source "${dict['installer_file']}"; koopa_assert_is_function "${dict['installer_fun']}"; "${dict['installer_fun']}" "$@"; return 0 )

koopa_debian_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='debian' \
        --system \
        "$@"
}
