#!/usr/bin/env bash

koopa::_linux_rsync() { # {{{1
    # """
    # rsync a desired prefix across virtual machines.
    # @note Updated 2020-11-18.
    #
    # We're enforcing use of '/usr/bin/rsync' here in case we're syncing
    # '/usr/local', which may have an updated copy of rsync installed.
    #
    # Potentially useful flags:
    # * --omit-dir-times
    # """
    local host_ip prefix rsync rsync_flags source_ip user
    koopa::assert_has_args "$#"
    rsync='/usr/bin/rsync'
    koopa::assert_is_installed "$rsync"
    rsync_flags="$(koopa::rsync_flags)"
    while (("$#"))
    do
        case "$1" in
            --rsync-flags=*)
                rsync_flags="${1#*=}"
                shift 1
                ;;
            --prefix=*)
                prefix="${1#*=}"
                shift 1
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    koopa::assert_is_set flags prefix source_ip
    host_ip="$(koopa::local_ip_address)"
    # Check for accidental sync from source machine.
    if [[ "$source_ip" == "$host_ip" ]]
    then
        koopa::note "On source machine: '${source_ip}'."
        return 0
    fi
    rsync_flags=("$rsync_flags")
    rsync_flags+=("--rsync-path=sudo ${rsync}")
    user="${USER:?}"
    koopa::h1 "Syncing '${prefix}' from '${source_ip}'."
    koopa::dl 'Flags' "${rsync_flags[*]}"
    koopa::sys_mkdir "$prefix"
    koopa::delete_broken_symlinks "$prefix"
    koopa::sys_set_permissions -ru "$prefix"
    rsync "${rsync_flags[@]}" \
        "${user}@${source_ip}:${prefix}/" \
        "${prefix}/"
    koopa::delete_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}

koopa::linux_rsync_system() { # {{{1
    # """
    # rsync virtual machine configuration.
    # @note Updated 2020-11-12.
    # """
    local app_prefix app_rsync_flags homebrew_prefix host_ip make_prefix pos \
        prefix refdata_prefix refdata_rsync_flags source_ip
    koopa::assert_has_args "$#"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_is_set source_ip
    host_ip="$(koopa::local_ip_address)"
    if [[ "$source_ip" == "$host_ip" ]]
    then
        koopa::note "Skipping rsync because '${host_ip}' is source machine."
        return 0
    fi
    # Allow user to input custom paths.
    if [[ "$#" -gt 0 ]]
    then
        for prefix in "$@"
        do
            koopa::_linux_rsync \
                --prefix="$prefix" \
                --source-ip="$source_ip"
        done
        return 0
    fi
    # Otherwise, sync the default paths. Be sure to sync app prefix before make
    # prefix, otherwise some symlinks won't resolve as expected.
    app_prefix="$(koopa::app_prefix)"
    if [[ -d "$app_prefix" ]]
    then
        # Skip programs that are specific to powerful multi-core VMs.
        readarray -t app_rsync_flags <<< "$(koopa::rsync_flags)"
        if ! koopa::is_powerful
        then
            app_rsync_flags+=(
                '--exclude=bcbio'
                '--exclude=cellranger'
                '--exclude=cellranger-atac'
                '--exclude=omicsoft'
            )
        fi
        koopa::_linux_rsync \
            --prefix="$app_prefix" \
            --rsync-flags="${app_rsync_flags[*]}" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping '${app_prefix}'."
    fi
    make_prefix="$(koopa::make_prefix)"
    if [[ -d "$make_prefix" ]]
    then
        koopa::_linux_rsync \
            --prefix="$make_prefix" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping '${make_prefix}'."
    fi
    refdata_prefix="$(koopa::refdata_prefix)"
    if [[ -d "$refdata_prefix" ]]
    then
        # Skip references that are specific to powerful multi-core VMs.
        readarray -t refdata_rsync_flags <<< "$(koopa::rsync_flags)"
        if ! koopa::is_powerful
        then
            refdata_rsync_flags+=(
                '--exclude=bcbio'
                '--exclude=cellranger'
                '--exclude=cellranger-atac'
                '--exclude=gtex'
            )
        fi
        koopa::_linux_rsync \
            --prefix="$refdata_prefix" \
            --rsync-flags="${refdata_rsync_flags[*]}" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping '${refdata_prefix}'."
    fi
    # Sync Homebrew, if installed.
    homebrew_prefix="$(koopa::homebrew_prefix)"
    if [[ -d "$homebrew_prefix" ]]
    then
        koopa::_linux_rsync \
            --prefix="$homebrew_prefix" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping '${homebrew_prefix}'."
    fi
    koopa::success "rsync from ${source_ip} was successful."
    return 0
}

