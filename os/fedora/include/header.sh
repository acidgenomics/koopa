#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

_koopa_assert_is_linux_fedora

if _koopa_has_sudo
then
    _koopa_assert_is_installed yum
    _koopa_assert_has_no_environments

    _koopa_build_chgrp /usr/local
    _koopa_update_ldconfig

    # Install gcc, if necessary.
    if [[ ! -x "$(command -v gcc)" ]]
    then
        sudo yum install -y gcc
    fi
fi
