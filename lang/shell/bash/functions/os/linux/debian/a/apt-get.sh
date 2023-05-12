#!/usr/bin/env bash

koopa_debian_apt_get() {
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2023-05-12.
    #
    # @section Automatic dpkg configuration:
    #
    # * confdef: If a conffile has been modified and the version in the package
    #   did change, always choose the default action without prompting. If there
    #   is no default action it will stop to ask the user unless
    #   '--force-confnew' or '--force-confold' is also been given, in which case
    #   it will use that to decide the final action.
    # * confmiss: If a conffile is missing and the version in the package did
    #   change, always install the missing conffile without prompting. This is
    #   dangerous, since it means not preserving a change (removing) made to the
    #   file.
    # * confold: If a conffile has been modified and the version in the package
    #   did change, always keep the old version without prompting, unless the
    #   '--force-confdef' is also specified, in which case the default action is
    #   preferred.
    # * confnew: If a conffile has been modified and the version in the package
    #   did change, always install the new version without prompting, unless the
    #   '--force-confdef' is also specified, in which case the default action is
    #   preferred.
    #
    # @seealso
    # - man apt-get
    # - https://manpages.ubuntu.com/manpages/jammy/en/man8/apt-get.8.html
    # - https://manpages.ubuntu.com/manpages/jammy/man7/debconf.7.html
    # - https://manpages.ubuntu.com/manpages/xenial/man1/dpkg.1.html
    # - https://wiki.debian.org/Multistrap/Environment
    # - https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-
    #     for-ubuntu-debian/
    # - https://serverfault.com/questions/197495/
    #     ubuntu-dpkg-non-interactive-installation
    # - https://savannah.gnu.org/maintenance/BobsGuideToSystemUpgrades/
    # - https://github.com/moby/moby/issues/27988#issuecomment-462809153
    # """
    local -A app
    local -a apt_args
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['debconf_set_selections']="$( \
        koopa_debian_locate_debconf_set_selections \
    )"
    koopa_assert_is_executable "${app[@]}"
    apt_args=(
        '--assume-yes'
        '--no-install-recommends'
        '--quiet'
        '-o' 'Dpkg::Options::=--force-confdef'
        '-o' 'Dpkg::Options::=--force-confold'
    )
    # Dropping into a subshell here so we don't inherit any shell changes.
    (
        koopa_add_to_path_end '/usr/sbin' '/sbin'
        # > export DEBCONF_ADMIN_EMAIL=''
        export DEBCONF_NONINTERACTIVE_SEEN='true'
        export DEBIAN_FRONTEND='noninteractive'
        export DEBIAN_PRIORITY='critical'
        export LANG='C'
        export LANGUAGE='C'
        export LC_ALL='C'
        export NEEDRESTART_MODE='a'
        "${app['cat']}" << END | koopa_sudo "${app['debconf_set_selections']}"
debconf debconf/frontend select Noninteractive
END
        koopa_sudo "${app['apt_get']}" "${apt_args[@]}" "$@"
    )
    return 0
}
