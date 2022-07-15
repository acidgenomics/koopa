#!/usr/bin/env bash
set -Eeuo pipefail

# Require this script to run as root.
[[ "${UID:?}" -eq 0 ]] || return 1

main() {
    # """
    # Bootstrap the Ubuntu builder AMI.
    # @note Updated 2022-07-15.
    #
    # @section Required dependencies:
    # - 'libgmp-dev' is required for 'haskell-stack' to install.
    #
    # @seealso
    # - https://www.serverlab.ca/tutorials/linux/administration-linux/
    #     how-to-check-and-set-timezone-in-ubuntu-20-04/
    # """
    export DEBCONF_NONINTERACTIVE_SEEN='true'
    export DEBIAN_FRONTEND='noninteractive'
    apt-get update
    apt-get upgrade --yes
    apt-get dist-upgrade --yes
    # Set time zone to New York (East Coast).
    echo 'tzdata tzdata/Areas select America' \
        | debconf-set-selections
    echo 'tzdata tzdata/Zones/America select New_York' \
        | debconf-set-selections
    # Needed for compiling software: 'gcc' 'g++' 'libc-dev' 'make'.
    apt-get \
        --no-install-recommends \
        --yes \
        install \
            'bash' \
            'ca-certificates' \
            'coreutils' \
            'curl' \
            'findutils' \
            'g++' \
            'gcc' \
            'git' \
            'libc-dev' \
            'libgmp-dev' \
            'locales' \
            'lsb-release' \
            'make' \
            'perl' \
            'procps' \
            'sudo' \
            'systemd' \
            'tzdata' \
            'unzip'
    apt-get autoremove --yes
    apt-get clean
    # Set the time zone.
    # > timedatectl list-timezones | grep 'America/New_York'
    timedatectl set-timezone 'America/New_York'
    # Check that settings are applied correctly.
    # > timedatectl
    # > cat '/etc/timezone'
    # Use UTF-8 by default.
    echo 'en_US.UTF-8 UTF-8' > '/etc/locale.gen'
    locale-gen --purge
    dpkg-reconfigure --frontend='noninteractive' locales
    update-locale LANG='en_US.UTF-8'
    # Enable passwordless sudo.
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' > '/etc/sudoers.d/sudo'
    chmod '0440' '/etc/sudoers.d/sudo'
}

main "$@"
