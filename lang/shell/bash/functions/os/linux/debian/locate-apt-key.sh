#!/usr/bin/env bash

# FIXME Now that Debian 11 is out, we may need to remove this.
# Check our scripts.

koopa_debian_locate_apt_key() {
    # """
    # NOTE 'apt-key' is deprecated and scheduled to be removed in Debian 11.
    # """
    koopa_locate_app \
        '/usr/bin/apt-key' \
        "$@"
}
