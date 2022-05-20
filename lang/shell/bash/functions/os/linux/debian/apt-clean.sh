#!/usr/bin/env bash

koopa_debian_apt_clean() {
    # """
    # Clean up apt after an install/uninstall call.
    # @note Updated 2021-11-02.
    #
    # Alternatively, can consider using 'autoclean' here, which is lighter
    # than calling 'clean'.

    # - 'clean': Cleans the packages and install script in
    #       '/var/cache/apt/archives/'.
    # - 'autoclean': Cleans obsolete deb-packages, less than 'clean'.
    # - 'autoremove': Removes orphaned packages which are not longer needed from
    #       the system, but not purges them, use the '--purge' option together
    #       with the command for that.
    #
    # @seealso
    # - https://askubuntu.com/questions/984797/
    # - https://askubuntu.com/questions/3167/
    # - https://github.com/hadolint/hadolint/wiki/DL3009
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes autoremove
    "${app[sudo]}" "${app[apt_get]}" --yes clean
    # > koopa_rm --sudo '/var/lib/apt/lists/'*
    return 0
}
