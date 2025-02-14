#!/usr/bin/env bash

koopa_debian_apt_add_repo() {
    # """
    # Add an apt repo.
    # @note Updated 2025-02-14.
    #
    # @section Debian Repository Format:
    #
    # The sources.list man page specifies this package source format:
    #
    # > deb uri distribution [component1] [component2] [...]
    #
    # and gives an example:
    #
    # > deb https://deb.debian.org/debian stable main contrib non-free
    #
    # The 'uri', in this case 'https://deb.debian.org/debian', specifies the
    # root of the archive. Often Debian archives are in the 'debian/' directory
    # on the server but can be anywhere else (many mirrors for example have it
    # in a 'pub/linux/debian' directory, for example).
    #
    # The 'distribution' part ('stable' in this case) specifies a subdirectory
    # in '$ARCHIVE_ROOT/dists'. It can contain additional slashes to specify
    # subdirectories nested deeper, eg. 'stable/updates'. 'distribution'
    # typically corresponds to 'Suite' or 'Codename' specified in the
    # 'Release' files.
    #
    # To download the index of the main component, apt would scan the 'Release'
    # file for hashes of files in the main directory.
    #
    # eg. 'https://deb.debian.org/debian/dists/testing/main/
    #      binary-i386/Packages.gz',
    # which would be listed in
    # 'https://deb.debian.org/debian/dists/testing/Release' as
    # 'main/binary-i386/Packages.gz'.
    #
    # Binary package indices are in 'binary-$arch' subdirectory of the component
    # directories. Source indices are in 'source' subdirectory.
    #
    # Package indices list specific source or binary packages relative to the
    # archive root.
    #
    # To avoid file duplication binary and source packages are usually kept in
    # the 'pool' subdirectory of the 'archive root'. The 'Packages' and
    # 'Sources' indices can list any path relative to 'archive root', however.
    # It is suggested that packages are placed in a subdirectory of 'archive
    # root' other than dists rather than directly in archive root. Placing
    # packages directly in the 'archive root' is not tested and some tools may
    # fail to index or retrieve packages placed there.
    #
    # The 'Contents' and 'Translation' indices are not architecture-specific and
    # are placed in 'dists/$DISTRIBUTION/$COMPONENT' directory, not architecture
    # subdirectory.
    #
    # @seealso
    # - https://wiki.debian.org/DebianRepository/Format
    # """
    local -A dict
    local -a components
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['distribution']=''
    dict['key_name']=''
    dict['key_prefix']="$(koopa_debian_apt_key_prefix)"
    dict['name']=''
    dict['prefix']="$(koopa_debian_apt_sources_prefix)"
    dict['signed_by']=''
    dict['url']=''
    components=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--component='*)
                components+=("${1#*=}")
                shift 1
                ;;
            '--component')
                components+=("${2:?}")
                shift 2
                ;;
            '--distribution='*)
                dict['distribution']="${1#*=}"
                shift 1
                ;;
            '--distribution')
                dict['distribution']="${2:?}"
                shift 2
                ;;
            '--key-name='*)
                dict['key_name']="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict['key_name']="${2:?}"
                shift 2
                ;;
            '--key-prefix='*)
                dict['key_prefix']="${1#*=}"
                shift 1
                ;;
            '--key-prefix')
                dict['key_prefix']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--signed-by='*)
                dict['signed_by']="${1#*=}"
                shift 1
                ;;
            '--signed-by')
                dict['signed_by']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict['key_name']:-}" ]]
    then
        dict['key_name']="${dict['name']}"
    fi
    koopa_assert_is_set \
        '--distribution' "${dict['distribution']}" \
        '--key-name' "${dict['key_name']}" \
        '--key-prefix' "${dict['key_prefix']}" \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    koopa_assert_is_dir \
        "${dict['key_prefix']}" \
        "${dict['prefix']}"
    dict['signed_by']="${dict['key_prefix']}/koopa-${dict['key_name']}.gpg"
    dict['file']="${dict['prefix']}/koopa-${dict['name']}.list"
    if [[ -f "${dict['signed_by']}" ]]
    then
        dict['string']="deb [arch=${dict['arch']} \
signed-by=${dict['signed_by']}] ${dict['url']} ${dict['distribution']} \
${components[*]}"
    else
        koopa_alert_note "GPG key does not exist at '${dict['signed_by']}'."
        dict['string']="deb [arch=${dict['arch']} ${dict['url']} \
${dict['distribution']} ${components[*]}"
    fi
    if [[ -f "${dict['file']}" ]]
    then
        koopa_alert_info "'${dict['name']}' repo exists at '${dict['file']}'."
        return 0
    fi
    koopa_alert "Adding '${dict['name']}' repo at '${dict['file']}'."
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}
