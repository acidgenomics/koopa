#!/usr/bin/env bash

koopa_debian_locate_apt_key() {
    # """
    # 'apt-key' is deprecated and scheduled to be removed in Debian 11.
    # """
    koopa_locate_app '/usr/bin/apt-key'
}
