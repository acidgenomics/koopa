#!/usr/bin/env bash

koopa_is_admin() {
    # """
    # Check that current user has administrator permissions.
    # @note Updated 2022-05-16.
    #
    # This check can hang on some systems with domain user accounts.
    #
    # Avoid prompting with '-n, --non-interactive', but note that this isn't
    # supported on all systems.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # Alternate approach:
    # > sudo -l
    #
    # List all users with sudo access:
    # > getent group 'sudo'
    #
    # - macOS: admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # See also:
    # - https://serverfault.com/questions/364334
    # - https://linuxhandbook.com/check-if-user-has-sudo-rights/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    case "${KOOPA_ADMIN:-}" in
        '0')
            return 1
            ;;
        '1')
            return 0
            ;;
    esac
    # Always return true for root user.
    koopa_is_root && return 0
    # Return false if 'sudo' program is not installed.
    koopa_is_installed 'sudo' || return 1
    # Early return true if user has passwordless sudo enabled.
    koopa_has_passwordless_sudo && return 0
    # Check if user is any accepted admin group.
    # Note that this step is very slow for Active Directory domain accounts.
    declare -A app=(
        [groups]="$(koopa_locate_groups)"
    )
    [[ -x "${app[groups]}" ]] || return 1
    declare -A dict=(
        [groups]="$("${app[groups]}")"
        [pattern]='\b(admin|root|sudo|wheel)\b'
    )
    [[ -n "${dict[groups]}" ]] || return 1
    koopa_str_detect_regex \
        --string="${dict[groups]}" \
        --pattern="${dict[pattern]}" \
        && return 0
    return 1
}
