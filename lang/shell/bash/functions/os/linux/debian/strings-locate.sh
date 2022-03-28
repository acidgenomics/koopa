#!/usr/bin/env bash

koopa_debian_locate_apt() { # {{{1
    koopa_locate_app '/usr/bin/apt'
}

koopa_debian_locate_apt_get() { # {{{1
    koopa_locate_app '/usr/bin/apt-get'
}

koopa_debian_locate_apt_key() { # {{{1
    # """
    # 'apt-key' is deprecated and scheduled to be removed in Debian 11.
    # """
    koopa_locate_app '/usr/bin/apt-key'
}

koopa_debian_locate_dpkg() { # {{{1
    koopa_locate_app '/usr/bin/dpkg'
}

koopa_debian_locate_dpkg_reconfigure() { # {{{1
    koopa_locate_app '/usr/sbin/dpkg-reconfigure'
}

koopa_debian_locate_gdebi() { # {{{1
    # """
    # Requires 'gdebi-core' to be installed.
    # """
    koopa_locate_app '/usr/bin/gdebi'
}

koopa_debian_locate_locale_gen() { # {{{1
    koopa_locate_app '/usr/sbin/locale-gen'
}

koopa_debian_locate_service() { # {{{1
    koopa_locate_app '/usr/sbin/service'
}

koopa_debian_locate_timedatectl() { # {{{1
    koopa_locate_app '/usr/bin/timedatectl'
}

koopa_debian_locate_unattended_upgrades() { # {{{1
    koopa_locate_app '/usr/bin/unattended-upgrades'
}

koopa_debian_locate_update_locale() { # {{{1
    koopa_locate_app '/usr/sbin/update-locale'
}
