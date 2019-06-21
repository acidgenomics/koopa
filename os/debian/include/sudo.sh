#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/shell/bash/include/functions.sh"

_koopa_assert_has_sudo
_koopa_assert_is_os_debian
_koopa_assert_is_installed apt-get
_koopa_assert_has_no_environments
_koopa_build_chgrp /usr/local
_koopa_update_ldconfig

sudo apt-get -y update
