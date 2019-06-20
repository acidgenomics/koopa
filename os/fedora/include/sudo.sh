#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/shell/bash/include/header.sh"

_koopa_assert_has_sudo
_koopa_assert_is_os_fedora
_koopa_assert_is_installed yum
_koopa_assert_has_no_environments

_koopa_build_chgrp /usr/local
_koopa_update_ldconfig

# Install gcc, if necessary.
if [[ ! -x "$(command -v gcc)" ]]
then
    sudo yum install -y gcc
fi
