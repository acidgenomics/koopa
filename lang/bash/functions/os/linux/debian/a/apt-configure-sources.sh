#!/usr/bin/env bash

# FIXME Ubuntu 24 has moved to a new format, defined in:
# /etc/apt/sources.list.d/ubuntu.sources

koopa_debian_apt_configure_sources() {
    # """
    # Configure apt sources.
    # @note Updated 2024-06-27.
    #
    # Note that new Debian 12 Docker base image moves configuration to
    # /etc/apt/sources.list.d/debian.sources
    #
    # Look up currently enabled sources with:
    # > grep -Eq '^deb\s' '/etc/apt/sources.list'
    #
    # Debian Docker images can also use snapshots:
    # http://snapshot.debian.org/archive/debian/20210326T030000Z
    #
    # @section Docker images:
    #
    # Debian 12 defaults:
    # > deb http://deb.debian.org/debian
    #       stable main
    # > deb http://deb.debian.org/debian-security
    #       stable-security main
    # > deb http://deb.debian.org/debian
    #       stable-updates main
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
    local -A app codenames dict urls
    local -a repos
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['os_codename']="$(koopa_debian_os_codename)"
    dict['os_id']="$(koopa_os_id)"
    dict['sources_list']="$(koopa_debian_apt_sources_file)"
    dict['sources_list_d']="$(koopa_debian_apt_sources_prefix)"
    # This is the case for Debian 12 Docker base image.
    if [[ ! -f "${dict['sources_list']}" ]]
    then
        koopa_alert_info "Skipping apt configuration at \
'${dict['sources_list']}'. File does not exist."
        return 0
    fi
    # Ubuntu 24 LTS has changed to new ubuntu.sources format.
    if koopa_is_ubuntu_like && \
        [[ -f '/etc/apt/sources.list.d/ubuntu.sources' ]]
    then
        koopa_alert_note "System is configured to use new 'ubuntu.sources'."
        return 0
    fi
    # Skip if sources list doesn't contain any deb definitions.
    if ! koopa_file_detect_regex \
        --file="${dict['sources_list']}" \
        --pattern='^deb\s'
    then
        koopa_alert_note "Failed to detect 'deb' in '${dict['sources_list']}'."
        return 0
    fi
    koopa_alert "Configuring apt sources in '${dict['sources_list']}'."
    codenames['main']="${dict['os_codename']}"
    codenames['security']="${dict['os_codename']}-security"
    codenames['updates']="${dict['os_codename']}-updates"
    urls['main']="$( \
        koopa_grep \
            --file="${dict['sources_list']}" \
            --pattern='^deb\s' \
            --regex \
        | koopa_grep \
            --fixed \
            --pattern=' main' \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    urls['security']="$( \
        koopa_grep \
            --file="${dict['sources_list']}" \
            --pattern='^deb\s' \
            --regex \
        | koopa_grep \
            --fixed \
            --pattern='security main' \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    if [[ -z "${urls['main']}" ]]
    then
        koopa_stop 'Failed to extract apt main URL.'
    fi
    if [[ -z "${urls['security']}" ]]
    then
        koopa_stop 'Failed to extract apt security URL.'
    fi
    urls['updates']="${urls['main']}"
    case "${dict['os_id']}" in
        'debian')
            # Can consider including 'backports' here.
            repos=('main')
            ;;
        'ubuntu')
            # Can consider including 'multiverse' here.
            repos=('main' 'restricted' 'universe')
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict['os_id']}'."
            ;;
    esac
    # Configure primary apt sources.
    if [[ -L "${dict['sources_list']}" ]]
    then
        koopa_rm --sudo "${dict['sources_list']}"
    fi
    # Configure secondary apt sources.
    if [[ -L "${dict['sources_list_d']}" ]]
    then
        koopa_rm --sudo "${dict['sources_list_d']}"
    fi
    if [[ ! -d "${dict['sources_list_d']}" ]]
    then
        koopa_mkdir --sudo "${dict['sources_list_d']}"
    fi
    read -r -d '' "dict[sources_list_string]" << END || true
deb ${urls['main']} ${codenames['main']} ${repos[*]}
deb ${urls['security']} ${codenames['security']} ${repos[*]}
deb ${urls['updates']} ${codenames['updates']} ${repos[*]}
END
    koopa_sudo_write_string \
        --file="${dict['sources_list']}" \
        --string="${dict['sources_list_string']}"
    return 0
}
