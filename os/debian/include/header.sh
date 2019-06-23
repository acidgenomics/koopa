#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

_koopa_assert_is_linux_debian

if _koopa_has_sudo
then
    _koopa_assert_has_no_environments
    _koopa_assert_is_installed apt-get

    _koopa_build_chgrp /usr/local
    _koopa_update_ldconfig

    sudo apt-get -y update
fi
