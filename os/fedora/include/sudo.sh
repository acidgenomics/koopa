#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/shell/bash/include/functions.sh"

assert_has_sudo
assert_is_os_fedora
assert_is_installed yum
assert_has_no_environments
build_chgrp /usr/local
sudo_update_ldconfig

# Install gcc, if necessary.
if [[ ! -x "$(command -v gcc)" ]]
then
    sudo yum install -y gcc
fi
