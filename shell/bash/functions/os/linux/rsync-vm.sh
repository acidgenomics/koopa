#!/usr/bin/env bash

koopa::rsync_vm() {
    # """
    # rsync virtual machine configuration.
    # @note Updated 2020-07-16.
    # """
    local app_prefix app_rsync_flags host_ip make_prefix pos prefix \
        refdata_prefix refdata_rsync_flags source_ip
    koopa::assert_has_args "$#"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            --source-ip)
                source_ip="$2"
                shift 2
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
    # Source check. Ensure that source and local (host) IP addresses are not
    # identical. If they are, early exit without error, as this script is called
    # inside 'configure-vm'.
    host_ip="$(koopa::local_ip_address)"
    if [[ "$source_ip" == "$host_ip" ]]
    then
        koopa::exit "Skipping rsync because \"${host_ip}\" is source machine."
    fi
    # Allow user to input custom paths.
    if [[ "$#" -gt 0 ]]
    then
        for prefix in "$@"
        do
            koopa::rsync_vm \
                --prefix="$prefix" \
                --source-ip="$source_ip"
        done
        return 0
    fi
    # Otherwise, sync the default paths. Be sure to sync app prefix before make
    # prefix, otherwise some symlinks won't resolve as expected, and chmod
    # can error.
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
        koopa::rsync_vm \
            --prefix="$app_prefix" \
            --rsync-flags="${app_rsync_flags[*]}" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping \"${app_prefix}\"."
    fi
    make_prefix="$(koopa::make_prefix)"
    if [[ -d "$make_prefix" ]]
    then
        koopa::rsync_vm \
            --prefix="$make_prefix" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping \"${make_prefix}\"."
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
        koopa::rsync_vm \
            --prefix="$refdata_prefix" \
            --rsync-flags="${refdata_rsync_flags[*]}" \
            --source-ip="$source_ip"
    else
        koopa::note "Skipping \"${refdata_prefix}\"."
    fi
    koopa::success "rsync from ${source_ip} was successful."
    return 0
}

