#!/usr/bin/env bash

koopa_debian_apt_configure_sources() {
    # """
    # Configure apt sources.
    # @note Updated 2022-03-09.
    #
    # Look up currently enabled sources with:
    # > grep -Eq '^deb\s' '/etc/apt/sources.list'
    #
    # Debian Docker images can also use snapshots:
    # http://snapshot.debian.org/archive/debian/20210326T030000Z
    #
    # @section AWS AMI instances:
    #
    # Debian 11 x86 defaults:
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye main
    # > deb http://security.debian.org/debian-security
    #       bullseye-security main
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye-updates main
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye-backports main
    #
    # Debian 11 ARM defaults:
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye main
    # deb http://security.debian.org/debian-security
    #     bullseye-security main
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye-updates main
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye-backports main
    #
    # Ubuntu 20 LTS x86 defaults:
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal main restricted
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates main restricted
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal universe
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates universe
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal multiverse
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates multiverse
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-backports main restricted universe multiverse
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security main restricted
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security universe
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security multiverse
    #
    # Ubuntu ARM defaults:
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal main restricted
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates main restricted
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal universe
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates universe
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal multiverse
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates multiverse
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-backports main restricted universe multiverse
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security main restricted
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security universe
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security multiverse
    # """
    local app codenames repos urls
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [os_codename]="$(koopa_os_codename)"
        [os_id]="$(koopa_os_id)"
        [sources_list]="$(koopa_debian_apt_sources_file)"
        [sources_list_d]="$(koopa_debian_apt_sources_prefix)"
    )
    koopa_alert "Configuring apt sources in '${dict[sources_list]}'."
    koopa_assert_is_file "${dict[sources_list]}"
    declare -A codenames=(
        [main]="${dict[os_codename]}"
        [security]="${dict[os_codename]}-security"
        [updates]="${dict[os_codename]}-updates"
    )
    declare -A urls=(
        [main]="$( \
            koopa_grep \
                --file="${dict[sources_list]}" \
                --pattern='^deb\s' \
                --regex \
            | koopa_grep \
                --fixed \
                --pattern=" ${codenames[main]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
        )"
        [security]="$( \
            koopa_grep \
                --file="${dict[sources_list]}" \
                --pattern='^deb\s' \
                --regex \
            | koopa_grep \
                --fixed \
                --pattern=" ${codenames[security]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f '2' \
        )"
    )
    if [[ -z "${urls[main]}" ]]
    then
        koopa_stop 'Failed to extract apt main URL.'
    fi
    if [[ -z "${urls[security]}" ]]
    then
        koopa_stop 'Failed to extract apt security URL.'
    fi
    urls[updates]="${urls[main]}"
    case "${dict[os_id]}" in
        'debian')
            # Can consider including 'backports' here.
            repos=('main')
            ;;
        'ubuntu')
            # Can consider including 'multiverse' here.
            repos=('main' 'restricted' 'universe')
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict[os_id]}'."
            ;;
    esac
    # Configure primary apt sources.
    if [[ -L "${dict[sources_list]}" ]]
    then
        koopa_rm --sudo "${dict[sources_list]}"
    fi
    sudo "${app[tee]}" "${dict[sources_list]}" >/dev/null << END
deb ${urls[main]} ${codenames[main]} ${repos[*]}
deb ${urls[security]} ${codenames[security]} ${repos[*]}
deb ${urls[updates]} ${codenames[updates]} ${repos[*]}
END
    # Configure secondary apt sources.
    if [[ -L "${dict[sources_list_d]}" ]]
    then
        koopa_rm --sudo "${dict[sources_list_d]}"
    fi
    if [[ ! -d "${dict[sources_list_d]}" ]]
    then
        koopa_mkdir --sudo "${dict[sources_list_d]}"
    fi
    return 0
}
